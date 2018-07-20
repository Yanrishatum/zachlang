package zachlang.custom;

import zachlang.core.HardwareModule;

class NumberInput extends HardwareModule
{
  
  private var num:Port;
  
  private var writing:Bool;
  
  public function new()
  {
    super();
    addRegister(num = new Port("num", false, true, true));
    sleeping = true;
  }
  
  public function send(val:Int)
  {
    writing = true;
    num.write(val);
    flushWrites();
  }
  
  override function step() {
    if (writing && num.write(num.value)) writing = false;
  }
  
}