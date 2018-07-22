package zachlang.exa;

import zachlang.core.HardwareModule.HWSS;

class FileRegister extends Register
{
  
  private var exa:ExaProto;
  
  public function new(exa:ExaProto)
  {
    super("f", true, true, 0);
    this.exa = exa;
    allowKeywords = true;
  }
  
  public function attach(file:ExaFile)
  {
    this.value = file.id;
  }
  
  public function detach():Void
  {
    this.value = 0;
  }
  
  override function read():Bool {
    if (exa.file == null) throw @:privateAccess exa.runtimeError("Can't read from F register: No file held!");
    switch(exa.file.cursorType())
    {
      case 0:
        return false;
      case 1:
        value = exa.file.readInteger();
        storedKeyword = false;
      case 2:
        keyword = exa.file.readKeyword();
        storedKeyword = true;
    }
    return true;
  }
  
  override function write(value:Int):Bool {
    if (exa.file == null) throw @:privateAccess exa.runtimeError("Can't write to F register: No file held!");
    exa.file.writeInteger(value);
    return true;
  }
  
  override function writeKeyword(value:String):Bool {
    if (exa.file == null) throw @:privateAccess exa.runtimeError("Can't write to F register: No file held!");
    exa.file.writeKeyword(value);
    return true;
  }
  
}