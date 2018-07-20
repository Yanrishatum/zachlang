package zachlang.registers;

import zachlang.core.HardwareModule;

class Port extends Register
{
  public var blocking:Bool;
  public var alwaysReadable:Bool;
  
  public var pipe:PortPipe;
  public var state:PortState;
  public var module:HardwareModule;
  
  public function new(name:String, writeable:Bool = true, readable:Bool = true, blocking:Bool = true, alwaysReadable:Bool = false, value:Int = 0)
  {
    super(name, writeable, readable, value);
    this.blocking = blocking;
    this.state = PortState.Idle;
    connectToPipe(new PortPipe(blocking));
  }
  
  public function reset():Void
  {
    state = Idle;
    pipe.writes.remove(this);
    pipe.latestValue = 0;
    value = 0;
  }
  
  public function listen():Void
  {
    if (!pipe.canRead(this))
    {
      state = PortState.Listen;
    }
    else
    {
      module.onPipeDataAvailable(this);
    }
  }
  
  // Happens when there is data in pipe
  public function notifyWrite(by:Port)
  {
    if (state == PortState.Listen)
    {
      state = Idle;
      module.onPipeDataAvailable(this);
    }
    else if (state == PortState.Read)
    {
      // pipe.read(this);
      module.onReadResolved(this, by);
    }
  }
  
  // Happens when this port was removed from write queue and read by other port.
  public function notifyRead(by:Port)
  {
    if (state == PortState.Write)
    {
      state = WriteDone;
      module.onWriteResolved(this, by);
    }
  }
  
  public function hasDataInPipe():Bool
  {
    if (pipe.writes.length > 0) return true;
    for(port in pipe.onRequestWrites) if (port.getPersistentData()) return true;
    return false;
  }
  
  override public function read():Bool
  {
    state = Read;
    if (pipe.read(this))
    {
      state = Idle;
      return true;
    }
    return false;
  }
  
  override public function write(v:Int):Bool
  {
    if (state == Idle)
    {
      value = v;
      state = Writing;
    }
    else if (state == WriteDone)
    {
      state = Idle;
      return true;
    }
    return !blocking;
  }
  
  public function flush():Void
  {
    if (state == Writing)
    {
      state = Write;
      pipe.write(this);
    }
  }
  
  public function getPersistentData():Bool
  {
    return alwaysReadable;
  }
  
  public function connectToPipe(pipe:PortPipe)
  {
    if (pipe.blocking != this.blocking) throw new HardwareError("Connecting non-blocking pipe to blocking pipe!", 0, HardwareErrorType.Hardware);
    
    if (this.pipe != null)
    {
      this.pipe.writes.remove(this);
      this.pipe.onRequestWrites.remove(this);
      this.pipe.ports.remove(this);
    }
    state = Idle;
    this.pipe = pipe;
    pipe.ports.push(this);
    if (alwaysReadable) pipe.onRequestWrites.push(this);
  }
  
}
