package zachlang;

import haxe.io.StringInput;
import haxe.io.Input;
import zachlang.tis.TisExpr;
import zachlang.tis.TisTokenizer;
import zachlang.core.Hardware;

class TIS100 extends Hardware<TisExpr>
{
  
  private static var tokenizer:TisTokenizer = new TisTokenizer();
  
  public var acc:Register;
  public var bak:Register;
  public var left:Port;
  public var right:Port;
  public var up:Port;
  public var down:Port;
  
  private var blockWrite:RegisterType;
  
  public function new()
  {
    super("TIS-100");
    addRegister(acc = new Register("acc", true, true));
    addRegister(bak = new Register("bak", false, false));
    addRegister(left = new Port("left", true, true, true));
    addRegister(right = new Port("right", true, true, true));
    addRegister(up = new Port("up", true, true, true));
    addRegister(down = new Port("down", true, true, true));
  }
  
  override function compile(source:String):Void
  {
    this.source = source;
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
  
  override function execute(e:Expr<TisExpr>) {
    switch(e.e)
    {
      case TisExpr.Nop:
        // nothing
      case Swp:
        var tmp:Int = acc.value;
        acc.value = bak.value;
        bak.value = tmp;
      case Sav:
        bak.value = acc.value;
      case Neg:
        acc.value = -acc.value;
      case Mov(src, dst):
        if (readRegister(src, 0) && writeRegister(dst, stack[0]))
        {
          clearStack();
        }
        else blocked = true;
      case Add(src):
        if (readRegister(src, 0))
        {
          acc.value += stack[0];
          clearStack();
        }
        else blocked = true;
      case Sub(src):
        if (readRegister(src, 0))
        {
          acc.value -= stack[0];
          clearStack();
        }
        else blocked = true;
      case Jmp(label):
        goToLabel(label);
      case Jez(label):
        if (acc.value == 0) goToLabel(label);
      case Jnz(label):
        if (acc.value != 0) goToLabel(label);
      case Jlz(label):
        if (acc.value < 0) goToLabel(label);
      case Jgz(label):
        if (acc.value > 0) goToLabel(label);
      case Jro(src):
        if (readRegister(src, 0))
        {
          jump(stack[0]);
          clearStack();
        }
        else blocked = true;
    }
    sleeping = blocked;
  }
  
  override function readSpecialRegister(name:String, to:Int):Bool {
    if (name.toLowerCase() == "nil")
    {
      stack[to] = 0;
      return true;
    }
    return false;
  }
  
  override function writeSpecialRegister(name:String, value:Int):Bool {
    if (name.toLowerCase() == "nil")
    {
      return true;
    }
    return false;
  }
  
}
