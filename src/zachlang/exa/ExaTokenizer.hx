package zachlang.exa;

import zachlang.core.Tokenizer;
import zachlang.core.Hardware;
import haxe.io.Input;

class ExaTokenizer extends Tokenizer<ExaToken, ExaExpr>
{
  
  public function new()
  {
    super();
  }
  
  override function tokenize(hw:Hardware<ExaExpr>, input:Input):Array<Expr<ExaExpr>> {
    assign(hw, input);
    var tk:ExaToken = token();
    var list:Array<Expr<ExaExpr>> = new Array();
    var debug:Bool = false;
    while(true)
    {
      switch(tk)
      {
        case TEof: return list;
        case TBreakpoint: debug = true;
        case TId(id):
          switch(id.toLowerCase())
          {
            case "mark":
              tk = token();
              switch(tk)
              {
                case TId(name):
                  if (hw.labels.exists(name))
                  {
                    throw new HardwareError("Label with name '" + name + "' already exists!", line, HardwareErrorType.Compiler);
                  }
                  hw.labels.set(name, line);
                default:
                  throw new HardwareError("Could not create mark, expected mark name, got: " + tk, line, HardwareErrorType.Compiler);
              }
              
            // Value manipulation
            case "copy": list.push(makeExpr(Copy(getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "addi": list.push(makeExpr(AddI(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "subi": list.push(makeExpr(SubI(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "muli": list.push(makeExpr(MulI(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "divi": list.push(makeExpr(DivI(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "modi": list.push(makeExpr(ModI(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "swizz": list.push(makeExpr(Swizz(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            
            // Branching
            //mark(label)
            case "jump": list.push(makeExpr(Jump(getLabel()), debug));
            case "tjmp": list.push(makeExpr(TJump(getLabel()), debug));
            case "fjmp": list.push(makeExpr(FJump(getLabel()), debug));
            
            // Testing
            case "test":
              var left:RegisterType = getRegister(true, true, false);
              switch(left)
              {
                case VSpecial(kind) if (kind.toLowerCase() == "mrd"):
                  list.push(makeExpr(TestMrd, debug));
                case VSpecial(kind) if (kind.toLowerCase() == "eof"):
                  list.push(makeExpr(TestEof, debug));
                default:
                  var op:ExaTestOp = getOp();
                  list.push(makeExpr(Test(left, getRegister(true, true, false), op), debug));
              }
            
            // Lifecycle
            case "repl": list.push(makeExpr(Repl(getLabel()), debug));
            case "halt": list.push(makeExpr(Halt, debug));
            case "kill": list.push(makeExpr(Kill, debug));
            
            // Movement
            case "link": list.push(makeExpr(Link(getRegister(true, true, false)), debug));
            case "host": list.push(makeExpr(Host(getRegister(false, false, true)), debug));
            
            // Communication
            case "mode": list.push(makeExpr(Mode));
            case "void": list.push(makeExpr(Void(getRegister(false, false, true)), debug)); // Void(M) : Read+Discard / Void(F) : Remove
            //Test(VSpecial("MRD");
            
            // Files
            case "make": list.push(makeExpr(Make, debug));
            case "grab": list.push(makeExpr(Grab(getRegister(true, true, false)), debug));
            case "file": list.push(makeExpr(File(getRegister(false, false, true)), debug));
            case "seek": list.push(makeExpr(Seek(getRegister(true, true, false)), debug));
            //Void(F)
            case "drop": list.push(makeExpr(Drop, debug));
            case "wipe": list.push(makeExpr(Wipe, debug));
            //Test(VSpecial("EOF"));
            
            // Misc
            //Note
            case "noop": list.push(makeExpr(Noop, debug));
            case "rank": list.push(makeExpr(Rand(getRegister(true, true, false), getRegister(true, true, false), getRegister(false, false, true)), debug));
            
            default:
              
          }
          debug = false;
        default:
          
      }
      tk = token();
    }
    return list;
  }
  
  private function getRegister(allowNumber:Bool, validateReadable:Bool, validateWriteable:Bool):RegisterType
  {
    inline function validateRegister(reg:Register)
    {
      if (validateWriteable && !reg.writeable)
        throw new HardwareError("Register " + reg.name + " is unwriteable!", line, HardwareErrorType.Compiler);
      if (validateReadable && !reg.readable)
        throw new HardwareError("Register " + reg.name +" is unreadable!", line, HardwareErrorType.Compiler);
    }
    
    var tk:ExaToken = token();
    switch(tk)
    {
      case TInt(i):
        if (allowNumber)
          return RegisterType.VValue(i);
        else
          throw new HardwareError("Expected register, got number", line, HardwareErrorType.Compiler);
      case TMinus:
        if (allowNumber)
          return RegisterType.VValue(-getInt());
        else 
          throw new HardwareError("Expected register, got number", line, HardwareErrorType.Compiler);
      case TKeyword(str):
        if (allowNumber)
          return RegisterType.VKeyword(str);
        else 
          throw new HardwareError("Expected register, got keyword", line, HardwareErrorType.Compiler);
      case TId(str):
        var reg:Register = hw.registers.get(str.toLowerCase());
        if (reg != null)
        {
          validateRegister(reg);
          return RegisterType.VRegister(reg);
        }
        var port:Port = hw.ports.get(str.toLowerCase());
        if (port != null)
        {
          validateRegister(port);
          return RegisterType.VPort(port);
        }
        switch(str.toLowerCase())
        {
          case "null": return RegisterType.VSpecial("null");
          case "eof": return RegisterType.VSpecial("eof");
          case "mrd": return RegisterType.VSpecial("mrd");
          default:
            throw new HardwareError("Unknown register name: " + str, line, HardwareErrorType.Compiler);
        }
      default:
        throw new HardwareError("Expected register, got " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  private function getLabel():String
  {
    var tk:ExaToken = token();
    switch(tk)
    {
      case TId(str):
        return str;
      default:
        throw new HardwareError("Expected label name, got: " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  private function getInt():Int
  {
    var tk:ExaToken = token();
    switch(tk)
    {
      case TInt(i): return i;
      default: throw new HardwareError("Expected integer value, got: " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  private function getOp():ExaTestOp
  {
    var tk:ExaToken = token();
    switch(tk)
    {
      case TOp(op): return op;
      default: throw new HardwareError("Expected =, > or <, got: " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  override function token():ExaToken
  {
    var char:Int;
    if (this.char == -1)
    {
      char = readChar();
    }
    else 
    {
      char = this.char;
      this.char = -1;
    }
    while(true)
    {
      switch(char)
      {
        case 0: return TEof;
        case 32, 9, 13, ','.code:
          
        case 10:
          line++;
        case '-'.code: return TMinus;
        case '>'.code: return TOp(TGt);
        case '<'.code: return TOp(TLt);
        case '='.code: return TOp(TEq);
        case 48,49,50,51,52,53,54,55,56,57: // numbers
          var n:Int = char - 48;
          while(true)
          {
            char = readChar();
            switch(char)
            {
              case 48,49,50,51,52,53,54,55,56,57:
                n = n * 10 + (char - 48);
              default:
                this.char = char;
                return TInt(n);
            }
          }
        case "@".code: // Line-comment, not in specs.
          
          while(true)
          {
            char = readChar();
            if (char == 10) break;
            if (char == 0) return TEof;
          }
          continue;
        case "'".code, '"'.code:
          var interruptCode:Int = char;
          var kw:StringBuf = new StringBuf();
          while(true)
          {
            char = readChar();
            if (char == 0) throw new HardwareError("Unterminated keyword!", line, HardwareErrorType.Compiler);
            if (char == interruptCode)
            {
              return TKeyword(kw.toString());
            }
            kw.addChar(char);
          }
        case '!'.code: return TBreakpoint;
        // case ':'.code:
          // throw new HardwareError("Invalid character '" + String.fromCharCode(char) + "'", line, HardwareErrorType.Compiler);
        default:
          var id:String = String.fromCharCode(char);
          while(true)
          {
            char = readChar();
            switch(char)
            {
              case "@".code, ",".code, 10, 32, 9, 13, 0:
                this.char = char;
                if (id.toLowerCase() == "note")
                {
                  while(true)
                  {
                    char = readChar();
                    if (char == 10) break;
                    if (char == 0) return TEof;
                  }
                  this.char = char;
                  break;
                }
                // trace(id);
                return TId(id);
              default:
                id += String.fromCharCode(char);
            }
          }
          continue;
      }
      char = readChar();
    }
    
    return null;
  }
  
}