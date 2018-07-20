package zachlang;

import zachlang.core.HardwareModule;

class ZachPC
{
  
  private var hardwares:Array<HardwareModule>;
  
  public var paused:Bool;
  
  public var error:HardwareError;
  
  private var sleeping:Bool;
  
  public function new()
  {
    hardwares = new Array();
  }
  
  public function addHardware(hw:HardwareModule):Void
  {
    hardwares.push(hw);
    hw.reset();
  }
  
  public function reset():Void
  {
    for (hw in hardwares) hw.reset();
  }
  
  public function update():Void
  {
    if (paused) return;
    error = null;
    var interrupt:HardwareModule = null;
    var asleep:Int = 0;
    if (sleeping)
    {
      for (hw in hardwares)
      {
        try 
        {
          hw.tick();
        }
        catch(e:HardwareError)
        {
          error = e;
          error.hardware = hw;
          interrupt = hw;
        }
      }
    }
    
    for (hw in hardwares)
    {
      try
      {
        hw.step();
      }
      catch(e:HardwareError)
      {
        error = e;
        error.hardware = hw;
        interrupt = hw;
      }
    }
    for (hw in hardwares)
    {
      try
      {
        hw.flushWrites();
      }
      catch (e:HardwareError)
      {
        error = e;
        error.hardware = hw;
        interrupt = hw;
      }
      if (hw.sleeping) asleep++;
    }
    if (asleep == hardwares.length) sleeping = true;
    if (interrupt != null)
    {
      trace(interrupt);
      trace(error);
      pause();
    }
  }
  
  public function pause()
  {
    paused = true;
  }
  
  public function resume()
  {
    paused = false;
  }
  
}