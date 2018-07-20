package zachlang;

import zachlang.csm.CSMExpr;
import zachlang.csm.CSMTokenizer;
import haxe.io.StringInput;
import zachlang.core.Hardware;

class ChengShangMicro extends Hardware<CSMExpr>
{
  // Meta flags:
  // 1/-1: Conditionals
  // 2: Init flag
  // 4: Init: Executed
  public static inline var META_CONDITIONAL_TRUE:Int = 2;
  public static inline var META_CONDITIONAL_FALSE:Int = 1;
  public static inline var META_CONDITIONAL_MASK:Int = 1|2;
  public static inline var META_INIT:Int = 4;
  public static inline var META_INIT_DONE:Int = 8;
  
  private static var tokenizer:CSMTokenizer = new CSMTokenizer();
  
  public var acc:Register;
  public var dat:Register;
  public var p0:Port;
  public var p1:Port;
  public var x0:Port;
  public var x1:Port;
  public var x2:Port;
  public var x3:Port;
  
  private var test:Int;
  
  private var sleepTicks:Int;
  
  public function new()
  {
    // super("诚尚Micro");
    super("ChengShangMicro");
    addRegister(acc = new Register("acc", true, true));
    addRegister(dat = new Register("dat", true, true));
    addRegister(p0 = new Port("p0", true, true, false));
    addRegister(p1 = new Port("p1", true, true, false));
    addRegister(x0 = new Port("x0", true, true, true));
    addRegister(x1 = new Port("x1", true, true, true));
    addRegister(x2 = new Port("x2", true, true, true));
    addRegister(x3 = new Port("x3", true, true, true));
  }
  
  override function compile(source:String):Void
  {
    this.source = source;
    program = tokenizer.tokenize(this, new StringInput(source));
  }
  
  override function reset() {
    test = 0;
    for (expr in program)
    {
      expr.meta &= ~META_INIT_DONE;
    }
    super.reset();
  }
  
  override function tick() {
    if (sleepTicks > 0)
    {
      sleepTicks--;
      if (sleepTicks == 0) sleeping = false;
    }
    super.tick();
  }
  
  override function step() {
    if (sleeping) return;
    super.step();
  }
  
  override function execute(e:Expr<CSMExpr>) {
    if (sleeping)
    {
      blocked = true;
      return;
    }
    switch(e.e)
    {
      // Basic
      case Nop:
        // Nothing
      case Mov(src, dst):
        if (readRegister(src, 0) && writeRegister(dst, stack[0]))
        {
          clearStack();
        }
        else blocked = true;
      case Jmp(label):
        goToLabel(label);
      case Slp(time):
        if (readRegister(time, 0))
        {
          if (stack[0] > 0)
          {
            sleepTicks = stack[0];
            sleeping = true;
          }
          clearStack();
        }
        else blocked = true;
      case Slx(port):
        if (!sleeping)
        {
          sleeping = true;
          port.listen();
        }
        blocked = true;
      // Math
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
      case Mul(src):
        if (readRegister(src, 0))
        {
          acc.value *= stack[0];
          clearStack();
        }
        else blocked = true;
      case Not:
        if (acc.value == 0) acc.value = 100;
        else acc.value = 0;
      case Dgt(pos):
        if (readRegister(pos, 0))
        {
          acc.value = Std.int((acc.value / Math.pow(10, stack[0])) % 10);
          clearStack();
        }
        else blocked = true;
      case Dst(pos, val):
        readRegister(val, 1);
        if (readRegister(pos, 0) && stackState[1])
        {
          var mul:Float = Math.pow(10, stack[0]);
          var digit:Int = Std.int((acc.value / mul) % 10);
          acc.value += Std.int((stack[1] - digit) * mul);
          clearStack();
        }
        else blocked = true;
      
      // Test
      case Teq(left, right):
        readRegister(right, 1);
        if (readRegister(left, 0) && stackState[1])
        {
          test = stack[0] == stack[1] ? META_CONDITIONAL_TRUE : META_CONDITIONAL_FALSE;
          clearStack();
        }
        else blocked = true;
      case Tgt(left, right):
        readRegister(right, 1);
        if (readRegister(left, 0) && stackState[1])
        {
          test = stack[0] > stack[1] ? META_CONDITIONAL_TRUE : META_CONDITIONAL_FALSE;
          clearStack();
        }
        else blocked = true;
      case Tlt(left, right):
        readRegister(right, 1);
        if (readRegister(left, 0) && stackState[1])
        {
          test = stack[0] < stack[1] ? META_CONDITIONAL_TRUE : META_CONDITIONAL_FALSE;
          clearStack();
        }
        else blocked = true;
      case Tcp(left, right):
        readRegister(right, 1);
        if (readRegister(left, 0) && stackState[1])
        {
          test = stack[0] == stack[1] ? 0 : (stack[0] > stack[1] ? META_CONDITIONAL_TRUE : META_CONDITIONAL_FALSE);
          clearStack();
        }
        else blocked = true;
    }
  }
  
  override function readSpecialRegister(name:String, to:Int):Bool {
    if (name.toLowerCase() == "null")
    {
      stack[to] = 0;
      return true;
    }
    return false;
  }
  
  override function writeSpecialRegister(name:String, value:Int):Bool {
    if (name.toLowerCase() == "null")
    {
      return true;
    }
    return false;
  }
  
  private function markExpr(expr:Expr<CSMExpr>)
  {
    if ((expr.meta & META_INIT) == META_INIT) expr.meta |= META_INIT_DONE;
  }
  
  override function jump(distance:Int) {
    markExpr(program[position]);
    super.jump(distance);
  }
  
  override function goToLabel(label:String) {
    markExpr(program[position]);
    super.goToLabel(label);
  }
  
  override function nextInsutrction() {
    
    inline function next()
    {
      position++;
      if (position == program.length) position = 0;
    }
    var start:Int = position;
    
    if (!jumped)
    {
      markExpr(program[position]);
      next();
    }
    
    var expr:Expr<CSMExpr>;
    
    while (true)
    {
      expr = program[position];
      if (expr.meta == 0) break; // Regular block
      if ((expr.meta & META_INIT) == META_INIT) // Init block
      {
        if ((expr.meta & META_INIT_DONE) != META_INIT_DONE) break; // Not executed
      }
      else if ((expr.meta & META_CONDITIONAL_MASK) == test)
      {
        break; // Conditional met
      }
      next();
      if (position == start) break; // Made full loop.
    }
    
  }
  
  override function onPipeDataAvailable(local:Port) {
    sleeping = false; // slx command
    nextInsutrction();
  }
  
}
