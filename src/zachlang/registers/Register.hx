package zachlang.registers;

class Register
{
  public var name:String;
  public var writeable:Bool;
  public var readable:Bool;
  
  public var value:Int;
  
  public function new(name:String, writeable:Bool = true, readable:Bool = true, value:Int = 0)
  {
    this.name = name;
    this.writeable = writeable;
    this.readable = readable;
    this.value = value;
  }
  
  public function write(value:Int):Bool
  {
    this.value = value;
    return true;
  }
  
  public function read():Bool
  {
    return true;
  }
  
}
