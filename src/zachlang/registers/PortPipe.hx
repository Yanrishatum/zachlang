package zachlang.registers;

import haxe.CallStack;

class PortPipe
{
  public var ports:Array<Port>;
  
  public var blocking:Bool;
  
  public var latestValue:Int;
  
  public var writes:Array<Port>;
  public var onRequestWrites:Array<Port>; // Non blocking, have lowest priority.
  
  public function new(blocking:Bool)
  {
    this.ports = new Array();
    this.blocking = blocking;
    
    this.writes = new Array();
    this.onRequestWrites = new Array();
  }
  
  // Try to write in the pipe
  public function write(by:Port):Bool
  {
    if (writes.indexOf(by) == -1)
    {
      writes.push(by);
    }
    latestValue = by.value;
    
    for (p in ports)
    {
      if (p != by)
      {
        p.notifyWrite(by);
      }
    }
    return blocking ? writes.indexOf(by) == -1 : true;
  }
  
  public function read(by:Port):Bool
  {
    if (writes.length == 0)
    {
      for (port in onRequestWrites)
      {
        if (port.getPersistentData())
        {
          latestValue = by.value = port.value;
          return true;
        }
      }
      if (!blocking)
      {
        by.value = latestValue;
        return true;
      }
      return false;
    }
    var other:Port = writes.shift();
    by.value = other.value;
    other.notifyRead(by);
    return true;
  }
  
  public function canRead(by:Port):Bool
  {
    if (!blocking || writes.length > 0) return true;
    
    for (port in onRequestWrites) if (port.getPersistentData()) return true;
    
    return false;
  }
  
}
