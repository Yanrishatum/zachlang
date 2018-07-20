package zachlang.tis;

import haxe.io.Bytes;
import zachlang.core.HardwareModule;

class VisualizationModule extends HardwareModule
{
  
  public var input:Port;
  public var x:Int;
  public var y:Int;
  public var palette = [0, 0x333333, 0xAAAAAA, 0xFFFFFF, 0xFF0000];
  
  public var width:Int;
  public var height:Int;
  public var matrix:Bytes;
  
  public var state:VisualizationModuleState;
  
  public var onChange:Void->Void;
  
  public function new()
  {
    super();
    addRegister(input = new Port("in", true, true, true));
    state = WaitX;
    sleeping = true;
  }
  
  override function reset() {
    super.reset();
    clear();
    state = WaitX;
  }
  
  public function init(width:Int, height:Int)
  {
    this.width = width;
    this.height = height;
    matrix = Bytes.alloc(width * height);
    if (onChange != null) onChange();
  }
  
  override function step() {
    
    if (readPort(input, 0))
    {
      if (stack[0] < 0)
      {
        if (stack[0] == -1) state = WaitX;
        else 
        {
          clear();
        }
      }
      else 
      {
        switch(state)
        {
          case WaitX:
            x = stack[0];
            state = WaitY;
          case WaitY:
            y = stack[0];
            state = Drawing;
          case Drawing:
            plot(stack[0]);
        }
      }
      clearStack();
    }
  }
  
  private function plot(color:Int):Void
  {
    if (x < 0 || y < 0 || x >= width || y >= height || color < 0 || color >= palette.length) return; // OOB
    matrix.set(y * width + x, color);
    x++;
    if (onChange != null) onChange();
  }
  
  private function clear():Void
  {
    var i:Int = width * height - 1;
    while (i >= 0)
    {
      matrix.set(i, 0);
      i--;
    }
    if (onChange != null) onChange();
  }
  
}

enum VisualizationModuleState
{
  WaitX;
  WaitY;
  Drawing;
}