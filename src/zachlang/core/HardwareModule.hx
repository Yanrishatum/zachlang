package zachlang.core;

import haxe.ds.Vector;
import haxe.ds.Map;

typedef HWSS = HardwareStackState;

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
  
  private var stackState:Vector<HardwareStackState>;
  private var stack:Vector<Int>;
  private var keywords:Vector<String>;
  
  public function new()
  {
    this.registers = new Map();
    this.ports = new Map();
    this.stackState = new Vector(VALUE_STACK_LIMIT);
    this.stack = new Vector(VALUE_STACK_LIMIT);
    this.keywords = new Vector(VALUE_STACK_LIMIT);
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
  
  public function removeRegister(reg:Register):Void
  {
    if (Std.is(reg, Port))
    {
      var p:Port = cast reg;
      p.module = null;
      this.ports.remove(p.name);
    }
    else 
    {
      this.registers.remove(reg.name);
    }
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
        storeRegister(to, r);
        return true;
      case RegisterType.VPort(p):
        if (!p.readable) throw runtimeError("Trying to read unreachable port!");
        if (p.read())
        {
          storeRegister(to, p);
          return true;
        }
        return false;
      case RegisterType.VValue(v):
        storeInteger(to, v);
        return true;
      case RegisterType.VKeyword(v):
        storeKeyword(to, v);
        return true;
      case RegisterType.VSpecial(s):
        if(readSpecialRegister(s, to))
        {
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
      if (port.storedKeyword)
      {
        storeKeyword(to, port.keyword);
      }
      else
      {
        storeInteger(to, port.value);
      }
      
      return true;
    }
    return false;
  }
  
  private function writeRegister(t:RegisterType, value:Int, ?keyword:String):Bool
  {
    if (keyword == null) keyword = "";
    var isKeyword = keyword != "";
    switch(t)
    {
      case RegisterType.VRegister(r):
        if (!r.writeable) throw runtimeError("Trying to write unreachable register!");
        if (isKeyword && !r.allowKeywords) throw runtimeError("Trying to write keyword to integer register!");
        else if (!isKeyword && !r.allowIntegers) throw runtimeError("Trying to write integer to keyword register!");
        isKeyword ? r.writeKeyword(keyword) : r.write(value);
        return true;
      case RegisterType.VPort(p):
        if (!p.writeable) throw runtimeError("Trying to write unreachable port!");
        if (isKeyword && !p.allowKeywords) throw runtimeError("Trying to write keyword to integer register!");
        else if (!isKeyword && !p.allowIntegers) throw runtimeError("Trying to write integer to keyword register!");
        return isKeyword ? p.writeKeyword(keyword) : p.write(value);
      case RegisterType.VValue(v):
        throw "Only registers allowed!";
      case RegisterType.VKeyword(str):
        throw "Only registers allowed!";
      case RegisterType.VSpecial(v):
        return writeSpecialRegister(v, value, keyword);
        // if (!writeSpecialRegister(v, value)) throw runtimeError("Undefined register name!");
        // return true;
    }
  }
  
  private function writePort(p:Port, value:Int, ?keyword:String):Bool
  {
    if (!p.writeable) throw runtimeError("Trying to write unreachable port!");
    if (keyword == null) keyword = "";
    var isKeyword = keyword != "";
    if (isKeyword && !p.allowKeywords) throw runtimeError("Trying to write keyword to integer register!");
    else if (!isKeyword && !p.allowIntegers) throw runtimeError("Trying to write integer to keyword register!");
    return isKeyword ? p.writeKeyword(keyword) : p.write(value);
  }
  
  // In case of VSpecial register, read from it.
  private function readSpecialRegister(name:String, to:Int):Bool
  {
    return false;
  }
  
  // In case of VSpecial register, write to it.
  private function writeSpecialRegister(name:String, value:Int, keyword:String):Bool
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
  
  private function readInteger(from:Int):Int
  {
    if (stackState[from] != HWSS.INTVAL) throw runtimeError("[not an int] Can't read integer from stack @ " + from + "!");
    else return stack[from];
  }
  
  private function readKeyword(from:Int):String
  {
    if (stackState[from] != HWSS.KEYVAL) throw  runtimeError("[not a keyword] Can't read keyword from stack @ " + from + "!");
    else return keywords[from];
  }
  
  private inline function storeRegister(to:Int, reg:Register):Void
  {
    if (reg.storedKeyword) storeKeyword(to, reg.keyword);
    else storeInteger(to, reg.value);
  }
  
  private inline function storeInteger(to:Int, v:Int):Void
  {
    stack[to] = v;
    keywords[to] = "";
    stackState[to] = HWSS.INTVAL;
  }
  
  private inline function storeKeyword(to:Int, kw:String):Void
  {
    stack[to] = kw.charCodeAt(0);
    keywords[to] = kw;
    stackState[to] = HWSS.KEYVAL;
  }
  
  private inline function clearStack():Void
  {
    for (i in 0...VALUE_STACK_LIMIT)
    {
      stackState[i] = HWSS.EMPTY;
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