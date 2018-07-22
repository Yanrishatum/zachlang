package zachlang;

import zachlang.exa.ExaHardware;
import zachlang.core.HardwareModule.HWSS;
import haxe.io.StringInput;
import zachlang.core.Hardware;
import zachlang.exa.ExaExpr;
import zachlang.exa.ExaTestOp;
import zachlang.exa.ExaHost;
import zachlang.exa.ExaFile;
import zachlang.exa.FileRegister;
import zachlang.exa.ExaTokenizer;

class ExaProto extends Hardware<ExaExpr>
{
  
  
  private static var tokenizer:ExaTokenizer = new ExaTokenizer();
  
  public var xReg:Register;
  public var tReg:Register;
  public var fReg:FileRegister;
  public var mReg:Register;
  public var localMode:Bool;
  
  public var host:ExaHost;
  public var file:ExaFile;
  
  public function new()
  {
    super("EXA");
    addRegister(xReg = new Register("x", true, true, 0));
    addRegister(tReg = new Register("t", false, true, 0)); // Writeable?
    addRegister(fReg = new FileRegister(this));
    addRegister(mReg = new Port("m", true, true, true));
    
    ExaHost.hostZero.addExa(this);
    //addRegister(new Register("gx", true, true, 0));
    //addRegister(new Register("gy", true, true, 0));
    //addRegister(new Register("gz", true, true, 0));
    //addRegister(new Register("co", true, true, 0));
  }
  
  public function attach(node:ExaHardware):Void
  {
    for (other in node.ports)
    {
      var port:Port = new Port("#" + other.name.toLowerCase(), other.readable, other.writeable, true);
      addRegister(port);
      connectPort(port, other);
    }
  }
  
  public function detach(node:ExaHardware):Void
  {
    for (other in node.ports)
    {
      var port:Port = ports.get("#" + other.name.toLowerCase());
      port.disconnect();
      removeRegister(port);
    }
  }
  
  override function compile(source:String):Void
  {
    this.source = source;
    this.labels = new Map();
    
    program = tokenizer.tokenize(this, new StringInput(source));
  }
  
  override function reset() {
    super.reset();
    sleeping = false;
  }
  
  override function tick() {
    sleeping = false;
    super.tick();
  }
  
  override function step() {
    sleeping = false;
    super.step();
  }
  
  override function execute(e:Expr<ExaExpr>) {
    switch(e.e)
    {
      // Value manipulation
      case Copy(src, dst):
        if (readRegister(src, 0) && writeRegister(dst, stack[0], keywords[0]))
        {
          clearStack();
        }
        else blocked = true;
      case AddI(srcA, srcB, dst):
        if (readRegister(srcA, 0) && readRegister(srcB, 1) && writeRegister(dst, stack[0] + stack[1]))
        {
          clearStack();
        }
        else blocked = true;
      case SubI(srcA, srcB, dst):
        if (readRegister(srcA, 0) && readRegister(srcB, 1) && writeRegister(dst, stack[0] - stack[1]))
        {
          clearStack();
        }
        else blocked = true;
      case MulI(srcA, srcB, dst):
        if (readRegister(srcA, 0) && readRegister(srcB, 1) && writeRegister(dst, stack[0] * stack[1]))
        {
          clearStack();
        }
        else blocked = true;
      case DivI(srcA, srcB, dst):
        if (readRegister(srcA, 0) && readRegister(srcB, 1))
        {
          if (stack[1] == 0) throw runtimeError("Division by zero!");
          if (writeRegister(dst, Std.int(stack[0] / stack[1])))
            clearStack();
          else blocked = true;
        }
        else blocked = true;
      case ModI(srcA, srcB, dst):
        if (readRegister(srcA, 0) && readRegister(srcB, 1) && writeRegister(dst, stack[0] % stack[1]))
        {
          clearStack();
        }
        else blocked = true;
      case Swizz(src, order, dst):
        if (readRegister(src, 0) && readRegister(order, 1))
        {
          if (!stackState[2].isInteger())
          {
            if (stack[0] == 0) stack[2] = 0;
            else 
            {
              var s0:String = Std.string(Math.abs(stack[0]));
              var s1:String = Std.string(Math.abs(stack[1]));
              
              var i:Int = 0;
              var swizzled:Int = 0;
              var mul:Int = 1;
              while (i < s1.length)
              {
                var idx:Int = s1.charCodeAt(i) - '0'.code;
                if (idx != 0)
                {
                  swizzled += (s0.charCodeAt(idx - 1) - '0'.code) * mul;
                }
                i++;
                mul *= 10;
              }
              
              if (stack[0] < 0)
              {
                if (stack[1] >= 0) swizzled = -swizzled;
              }
              else if (stack[1] < 0) swizzled = -swizzled;
              
              // TODO: Solution without strings.
              
              stack[2] = swizzled;
            }
            stackState[2] = HWSS.INTVAL;
          }
          if (writeRegister(dst, stack[2]))
          {
            clearStack();
          }
          else blocked = true;
        }
        else blocked = true;
        
      // Branching
      case Jump(label):
        goToLabel(label);
      case TJump(label):
        if (tReg.value == 1) goToLabel(label);
      case FJump(label):
        if (tReg.value == 0) goToLabel(label);
      // Testing
      case Test(left, right, op):
        if (readRegister(left, 0) && readRegister(right, 1))
        {
          if ((stackState[0] == HWSS.KEYVAL && stackState[1] == HWSS.INTVAL) ||
              (stackState[0] == HWSS.INTVAL && stackState[1] == HWSS.KEYVAL))
          {
            tReg.value = 0;
          }
          else 
          {
            switch(op)
            {
              case TEq:
                if (stackState[0] == HWSS.KEYVAL) tReg.value = (keywords[0] == keywords[1]) ? 1 : 0;
                else tReg.value = (stack[0] == stack[1]) ? 1 : 0;
              case TLt:
                if (stackState[0] == HWSS.KEYVAL) tReg.value = (keywords[0] < keywords[1]) ? 1 : 0;
                else tReg.value = (stack[0] < stack[1]) ? 1 : 0;
              case TGt:
                if (stackState[0] == HWSS.KEYVAL) tReg.value = (keywords[0] > keywords[1]) ? 1 : 0;
                else tReg.value = (stack[0] > stack[1]) ? 1 : 0;
            }
          }
          clearStack();
        }
      // Lifecycle
      case Repl(label):
        throw runtimeError("Exa[proto] unimplemented instruction REPL!");
      case Halt:
        throw runtimeError("Exa[proto] unimplemented instruction HALT!");
      case Kill:
        throw runtimeError("Exa[proto] unimplemented instruction KILL!");
      // Movement
      case Link(src):
        if (readRegister(src, 0))
        {
          var other:ExaHost = host.links.get(stack[0]);
          if (other == null) throw runtimeError("Trying to traverse through inexisting link!");
          other.addExa(this);
          clearStack();
        }
        else blocked = true;
      case Host(dst):
        blocked = !writeRegister(dst, 0, host.name);
      
      // Communication
      case Mode:
        localMode = !localMode;
      case Void(dst): // Void(M) : Read+Discard / Void(F) : Remove
        if (readRegister(dst, 0))
        {
          clearStack();
        }
        else blocked = true;
      case TestMrd:
        throw runtimeError("Exa[proto] unimplemented instruction TEST MRD");
      
      // Files
      case Make:
        if (file != null) throw runtimeError("Can't make file: EXA already holding a file!");
        file = new ExaFile();
        fReg.attach(file);
      case Grab(src):
        if (file != null) throw runtimeError("Can't grab file: EXA already holding a file!");
        if (readRegister(src, 0))
        {
          file = host.findFile(readInteger(0));
          clearStack();
          if (file == null) throw runtimeError("Can't grab file: There is no files in proximity!");
          fReg.attach(file);
          host.removeFile(file);
        }
        else blocked = true;
      case File(dst):
        if (file == null) throw runtimeError("Can't read file ID: EXA does not hold a file!");
        blocked = !writeRegister(dst, file.id);
      case Seek(src):
        if (file == null) throw runtimeError("Can't seek file: EXA does not hold a file!");
        if (readRegister(src, 0))
        {
          file.seek(readInteger(0));
          clearStack();
        }
        else blocked = true;
      case Drop:
        if (file == null) throw runtimeError("Can't drop file: EXA does not hold a file!");
        host.addFile(file);
        fReg.detach();
        file = null;
      case Wipe:
        if (file == null) throw runtimeError("Can't wipe file: EXA does not hold a file!");
        fReg.detach();
        file = null;
      case TestEof:
        if (file == null) throw runtimeError("Can't test file: EXA does not hold a file!");
        tReg.value = file.eof() ? 1 : 0;
        
      // Misc
      case Noop:
        // nothing
      case Rand(min, max, dst):
        if (readRegister(min, 0) && readRegister(max, 1))
        {
          if (stackState[2].isEmpty())
          {
            stackState[2] = HWSS.INTVAL;
            if (stack[0] == stack[1]) stack[2] = stack[0];
            else stack[2] = stack[0] + Std.int(Math.random() * (stack[1] - stack[0] + 1));
          }
          if (writeRegister(dst, stack[2]))
          {
            clearStack();
          }
          else blocked = true;
        }
        else blocked = true;
    }
    
    sleeping = blocked;
  }
  
  override function readSpecialRegister(name:String, to:Int):Bool {
    if (name.charCodeAt(0) == '#'.code)
    {
      name = name.toLowerCase();
      for (p in ports)
      {
        if (name == p.name)
        {
          return readPort(p, to);
        }
      }
      return false;
    }
    if (name.toLowerCase() == "null")
    {
      storeInteger(to, 0);
      return true;
    }
    return false;
  }
  
  override function writeSpecialRegister(name:String, value:Int, keyword:String):Bool {
    if (name.charCodeAt(0) == '#'.code)
    {
      for (p in ports)
      {
        if (name == p.name)
        {
          return writePort(p, value, keyword);
        }
      }
      return false;
    }
    if (name.toLowerCase() == "null")
    {
      return true;
    }
    return false;
  }
  
}