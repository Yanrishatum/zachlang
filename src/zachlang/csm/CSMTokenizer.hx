package zachlang.csm;

import haxe.io.Input;
import zachlang.core.Tokenizer;
import zachlang.core.Hardware;

class CSMTokenizer extends Tokenizer<CSMToken, CSMExpr>
{
  public function new()
  {
    super();
  }
  
  override function tokenize(hw:Hardware<CSMExpr>, input:Input):Array<Expr<CSMExpr>> {
    assign(hw, input);
    var tk:CSMToken = token();
    var list:Array<Expr<CSMExpr>> = new Array();
    var debug:Bool = false;
    var initializer:Int = 0;
    var conditional:Int = 0;
    inline function getMeta():Int
    {
      return initializer | conditional;
    }
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
        case TInitializer:
          initializer = ChengShangMicro.META_INIT;
        case TPlus:
          conditional = ChengShangMicro.META_CONDITIONAL_TRUE;
        case TMinus:
          conditional = ChengShangMicro.META_CONDITIONAL_FALSE;
        case TId(id):
          switch(id.toLowerCase())
          {
            case "nop": list.push(makeExpr(Nop, debug, getMeta()));
            case "mov": list.push(makeExpr(Mov(getRegister(true, true, false), getRegister(false, false, true)), debug, getMeta()));
            case "jmp": list.push(makeExpr(Jmp(getLabel()), debug, getMeta()));
            case "slp": list.push(makeExpr(Slp(getRegister(true, true, false)), debug, getMeta()));
            case "slx": list.push(makeExpr(Slx(getPort()), debug, getMeta()));
            
            // Math
            case "add": list.push(makeExpr(Add(getRegister(true, true, false)), debug, getMeta()));
            case "sub": list.push(makeExpr(Sub(getRegister(true, true, false)), debug, getMeta()));
            case "mul": list.push(makeExpr(Mul(getRegister(true, true, false)), debug, getMeta()));
            case "not": list.push(makeExpr(Not, debug, getMeta()));
            case "dgt": list.push(makeExpr(Dgt(getRegister(true, true, false)), debug, getMeta()));
            case "dst": list.push(makeExpr(Dst(getRegister(true, true, false), getRegister(true, true, false)), debug, getMeta()));
            
            // Test
            case "teq": list.push(makeExpr(Teq(getRegister(true, true, false), getRegister(true, true, false)), debug, getMeta()));
            case "tgt": list.push(makeExpr(Tgt(getRegister(true, true, false), getRegister(true, true, false)), debug, getMeta()));
            case "tlt": list.push(makeExpr(Tlt(getRegister(true, true, false), getRegister(true, true, false)), debug, getMeta()));
            case "tcp": list.push(makeExpr(Tcp(getRegister(true, true, false), getRegister(true, true, false)), debug, getMeta()));
            
            default:
              throw new HardwareError("Unknown keyword: " + id, line, HardwareErrorType.Compiler);
          }
          debug = false;
          initializer = 0;
          conditional = 0;
        default:
          
      }
      tk = token();
    }
    return list;
  }
  
  private function getPort():Port
  {
    var tk:CSMToken = token();
    switch(tk)
    {
      case TId(str):
        var port:Port = hw.ports.get(str);
        if (port == null) throw new HardwareError("Unindentified pin name: " + str, line, HardwareErrorType.Compiler);
        if (!port.readable) throw new HardwareError("Specified pin is unreachable!", line, HardwareErrorType.Compiler);
        return port;
      default:
        throw new HardwareError("Expected pin register, got: " + tk, line, HardwareErrorType.Compiler);
    }
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
    
    var tk:CSMToken = token();
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
          default:
            throw new HardwareError("Unknown register name: " + str, line, HardwareErrorType.Compiler);
        }
      default:
        throw new HardwareError("Expected register, got " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  private function getLabel():String
  {
    var tk:CSMToken = token();
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
    var tk:CSMToken = token();
    switch(tk)
    {
      case TInt(i): return i;
      default: throw new HardwareError("Expected integer value, got: " + tk, line, HardwareErrorType.Compiler);
    }
  }
  
  override function token():CSMToken
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
        case '+'.code: return TPlus;
        case '@'.code: return TInitializer;
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
