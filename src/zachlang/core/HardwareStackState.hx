package zachlang.core;

abstract HardwareStackState(Int) from Int to Int
{
  
  public static inline var INTVAL:HardwareStackState = 1;
  public static inline var KEYVAL:HardwareStackState = 2;
  public static inline var EMPTY:HardwareStackState = 0;
  
  public inline function isInteger():Bool { return this == INTVAL; }
  public inline function isKeyword():Bool { return this == KEYVAL; }
  public inline function isEmpty():Bool { return this == EMPTY; }
  
  @:to
  public inline function asBool():Bool
  {
    return this != EMPTY;
  }
  
  @:to
  public static inline function toBool(v:HardwareStackState):Bool
  {
    return v != EMPTY;
  }
  
}