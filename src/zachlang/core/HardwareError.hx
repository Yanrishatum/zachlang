package zachlang.core;

import haxe.CallStack;

class HardwareError
{
  public var kind:HardwareErrorType;
  public var description:String;
  public var line:Int;
  public var hardware:HardwareModule;
  public var stack:Array<StackItem>;
  
  public function new(descr:String, line:Int, ?kind:HardwareErrorType)
  {
    this.description = descr;
    this.line = line;
    this.kind = kind == null ? HardwareErrorType.Hardware : kind;
    this.stack = CallStack.callStack();
    var i:Int = 0;
    this.stack.shift();
  }
  
  public function toString():String
  {
    return "[" + kind + "@" + line + "] " + description + "\n" + CallStack.toString(this.stack);
  }
  
}
