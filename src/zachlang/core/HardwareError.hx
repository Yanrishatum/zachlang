package zachlang.core;

class HardwareError
{
  public var kind:HardwareErrorType;
  public var description:String;
  public var line:Int;
  public var hardware:HardwareModule;
  
  public function new(descr:String, line:Int, ?kind:HardwareErrorType)
  {
    this.description = descr;
    this.line = line;
    this.kind = kind == null ? HardwareErrorType.Hardware : kind;
  }
  
  public function toString():String
  {
    return "[" + kind + "@" + line + "] " + description;
  }
  
}
