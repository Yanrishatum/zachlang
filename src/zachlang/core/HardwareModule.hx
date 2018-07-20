package zachlang.core;

import haxe.ds.Vector;
import haxe.ds.Map;

// Base for all connectable modules.
class HardwareModule
{
  
  private static inline var VALUE_STACK_LIMIT:Int = 4;
  
  public var registers:Map<String, Register>;
  public var ports:Map<String, Port>;
  
  // Is blocked by some read/write operation.
  public var blocked:Bool;
  // Is in "sleep" mode.
  public var sleeping:Bool;
  
  private var stackState:Vector<Bool>;
  private var stack:Vector<Int>;
  
  public function new()
  {
    this.registers = new Map();
    this.ports = new Map();
    this.stackState = new Vector(VALUE_STACK_LIMIT);
    this.stack = new Vector(VALUE_STACK_LIMIT);
  }
  
  public function addRegister(reg:Register):Void
  {
    if (Std.is(reg, Port))
    {
      var p:Port = cast reg;
      p.module = this;
      this.ports.set(p.name, p);
    }
    else this.registers.set(reg.name, reg);
  }
  
  public function connectPort(local:Port, remote:Port):Void
  {
    local.connectToPipe(remote.pipe);
  }
  
  private function readRegister(t:RegisterType, to:Int):Bool
  {
    if (to < 0 || to >= VALUE_STACK_LIMIT) throw runtimeError("Stack write out of bounds!");
    if (stackState[to]) return true; // Already read
    switch(t)
    {
      case RegisterType.VRegister(r):
        if (!r.readable) throw runtimeError("Trying to read unreachable register!");
        stack[to] = r.value;
        stackState[to] = true;
        return true;
      case RegisterType.VPort(p):
        if (!p.readable) throw runtimeError("Trying to read unreachable port!");
        if (p.read())
        {
          stack[to] = p.value;
          stackState[to] = true;
          return true;
        }
        return false;
      case RegisterType.VValue(v):
        stack[to] = v;
        stackState[to] = true;
        return true;
      case RegisterType.VSpecial(s):
        if(readSpecialRegister(s, to))
        {
          stackState[to] = true;
          return true;
        }
        return false;
    }
  }
  
  private function readPort(port:Port, to:Int):Bool
  {
    if (stackState[to]) return true; // Already read
    if (!port.readable) throw runtimeError("Trying to read unreachable port!");
    if (port.read())
    {
      stack[to] = port.value;
      stackState[to] = true;
      return true;
    }
    return false;
  }
  
  private function writeRegister(t:RegisterType, value:Int):Bool
  {
    switch(t)
    {
      case RegisterType.VRegister(r):
        if (!r.writeable) throw runtimeError("Trying to write unreachable register!");
        r.value = value;
        return true;
      case RegisterType.VPort(p):
        if (!p.writeable) throw runtimeError("Trying to write unreachable port!");
        return p.write(value);
      case RegisterType.VValue(v):
        throw "Only registers allowed!";
      case RegisterType.VSpecial(v):
        return writeSpecialRegister(v, value);
        // if (!writeSpecialRegister(v, value)) throw runtimeError("Undefined register name!");
        // return true;
    }
  }
  
  // In case of VSpecial register, read from it.
  private function readSpecialRegister(name:String, to:Int):Bool
  {
    return false;
  }
  
  // In case of VSpecial register, write to it.
  private function writeSpecialRegister(name:String, value:Int):Bool
  {
    return false;
  }
  
  // Reset the module state
  public function reset():Void
  {
    for (reg in registers) reg.value = 0;
    for (port in ports)
    {
      port.reset();
    }
    blocked = false;
    clearStack();
  }
  
  // Logic step
  public function step():Void
  {
    
  }
  
  // Called after all modules finished the step, ports should present written values.
  public function flushWrites():Void
  {
    for (port in ports) port.flush();
  }
  
  // Time step, called once all modules are in "sleeping" state.
  // !! Sleepning hardware still get step calls, it's up to specific hardware to ignore them.
  public function tick():Void
  {
    
  }
  
  private inline function clearStack():Void
  {
    for (i in 0...VALUE_STACK_LIMIT)
    {
      stackState[i] = false;
    }
  }
  
  private function runtimeError(message:String):HardwareError
  {
    throw new HardwareError(message, 0, HardwareErrorType.Runtime);
  }
  
  
  
  public function onPipeDataAvailable(local:Port):Void
  {
    
  }
  
  public function onWriteResolved(local:Port, by:Port):Void
  {
    
  }
  
  public function onReadResolved(local:Port, by:Port):Void
  {
    
  }
  
}