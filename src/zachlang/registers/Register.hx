package zachlang.registers;

class Register
{
  public var name:String;
  public var writeable:Bool;
  public var readable:Bool;
  
  public var value:Int;
  public var keyword:String;
  
  public var allowKeywords:Bool;
  public var allowIntegers:Bool;
  
  public var storedKeyword:Bool;
  
  public function new(name:String, writeable:Bool = true, readable:Bool = true, value:Int = 0)
  {
    this.name = name;
    this.writeable = writeable;
    this.readable = readable;
    this.allowIntegers = true;
    this.allowKeywords = false;
    this.value = value;
    this.keyword = "";
  }
  
  public function setMode(integers:Bool, keywords:Bool):Void
  {
    allowIntegers = integers;
    allowKeywords = keywords;
  }
  
  public function write(value:Int):Bool
  {
    this.value = value;
    storedKeyword = false;
    return true;
  }
  
  public function writeKeyword(value:String):Bool
  {
    this.keyword = value;
    storedKeyword = true;
    return true;
  }
  
  public function read():Bool
  {
    return true;
  }
  
  public function readKeyword():Bool
  {
    return true;
  }
  
}
