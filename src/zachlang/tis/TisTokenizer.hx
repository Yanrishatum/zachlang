package zachlang.tis;

import haxe.io.Input;
import zachlang.core.Tokenizer;
import zachlang.core.Hardware;

class TisTokenizer extends Tokenizer<TisToken, TisExpr>
{
  public function new()
  {
    super();
  }
  
  override function tokenize(hw:Hardware<TisExpr>, input:Input):Array<Expr<TisExpr>> {
    assign(hw, input);
    var tk:TisToken = token();
    var list:Array<Expr<TisExpr>> = new Array();
    var debug:Bool = false;
    while(true)
    {
      switch(tk)
      {
        case TEof: return list;
        case TBreakpoint: debug = true;
        case TLabel(name):
          if (hw.labels.exists(name))
          {
            throw new HardwareError("Label with name '" + name + "' already exists!", line, HardwareErrorType.Compiler);
          }
          hw.labels.set(name, line);
        case TId(id):
          switch(id.toLowerCase())
          {
            case "nop": list.push(makeExpr(Nop, debug));
            case "swp": list.push(makeExpr(Swp, debug));
            case "sav": list.push(makeExpr(Sav, debug));
            case "neg": list.push(makeExpr(Neg, debug));
            case "mov": list.push(makeExpr(Mov(getRegister(true, true, false), getRegister(false, false, true)), debug));
            case "add": list.push(makeExpr(Add(getRegister(true, true, false)), debug));
            case "sub": list.push(makeExpr(Sub(getRegister(true, true, false)), debug));
            case "jmp": list.push(makeExpr(Jmp(getLabel()), debug));
            case "jez": list.push(makeExpr(Jez(getLabel()), debug));
            case "jnz": list.push(makeExpr(Jnz(getLabel()), debug));
            case "jlz": list.push(makeExpr(Jlz(getLabel()), debug));
            case "jgz": list.push(makeExpr(Jgz(getLabel()), debug));
            case "jro": list.push(makeExpr(Jro(getRegister(true, true, false)), debug));
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
    
    var tk:TisToken = token();
    switch(tk)
    {
      case TInt(i):
        if (allowNumber)
          return RegisterType.VValue(i);
        else
          throw new HardwareError("Expected register, got number", line, HardwareErrorType.Compiler);
      case TNegate:
        if (allowNumber)
          return RegisterType.VValue(-getInt());
        else 
          throw new HardwareError("Expected register, got number", line, HardwareErrorType.Compiler);
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
          case "nil": return RegisterType.VSpecial("nil");
          case "any": return RegisterType.VSpecial("any");
          default:
            throw new HardwareError("Unknown register name: " + str, line, HardwareErrorType.Compiler);
        }
      default:
        throw new HardwareError("Expected register, got " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  private function getLabel():String
  {
    var tk:TisToken = token();
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
    var tk:TisToken = token();
    switch(tk)
    {
      case TInt(i): return i;
      default: throw new HardwareError("Expected integer value, got: " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  override function token():TisToken
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
        case '-'.code: return TNegate;
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
        case "#".code:
          
          while(true)
          {
            char = readChar();
            if (char == 10) break;
            if (char == 0) return TEof;
          }
          continue;
        case '!'.code: return TBreakpoint;
        case ':'.code:
          throw new HardwareError("Invalid character '" + String.fromCharCode(char) + "'", line, HardwareErrorType.Compiler);
        default:
          var id:String = String.fromCharCode(char);
          while(true)
          {
            char = readChar();
            switch(char)
            {
              case "#".code, ",".code, 10, 32, 9, 13, 0:
                this.char = char;
                return TId(id);
              case ":".code:
                return TLabel(id);
              default:
                id += String.fromCharCode(char);
            }
          }
      }
      char = readChar();
    }
    
    return null;
  }
  
}
