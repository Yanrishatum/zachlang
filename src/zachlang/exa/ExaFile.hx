package zachlang.exa;

import zachlang.core.HardwareModule.HWSS;

class ExaFile
{
  
  public var id:Int;
  public var length:Int;
  public var position:Int;
  public var iStorage:Array<Int>;
  public var kStorage:Array<String>;
  public var tStorage:Array<HWSS>;
  
  public function new(id:Int = 0)
  {
    this.id = id;
    this.length = 0;
    this.position = 0;
    this.iStorage = new Array();
    this.kStorage = new Array();
    this.tStorage = new Array();
  }
  
  public function cursorType():HWSS
  {
    if (eof()) return HWSS.EMPTY;
    return tStorage[position];
  }
  
  public function readInteger():Int
  {
    if (eof()) return 0; // TODO: Err?
    return iStorage[position++];
  }
  
  public function readKeyword():String
  {
    if (eof()) return "";
    return kStorage[position++];
  }
  
  public function writeInteger(v:Int):Void
  {
    tStorage[position] = HWSS.INTVAL;
    iStorage[position] = v;
    position++;
    if (position > length) length = position;
  }
  
  public function writeKeyword(v:String):Void
  {
    tStorage[position] = HWSS.KEYVAL;
    kStorage[position] = v;
    position++;
    if (position > length) length = position;
  }
  
  public function seek(dist:Int):Void
  {
    var pos:Int = position + dist;
    if (pos < 0) pos = 0;
    else if (pos > length) pos = length;
    
    position = pos;
  }
  
  public inline function eof():Bool
  {
    return position == length;
  }
  
}