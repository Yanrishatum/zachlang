package gui;

import hxd.Res;
import h2d.Text;
import zachlang.core.HardwareModule;
import h2d.Sprite;

class RegisterView extends AppSprite
{
  
  private var machine:HardwareModule;
  private var acc:Text;
  
  public function new(machine:HardwareModule, parent:Sprite)
  {
    this.machine = machine;
    super(parent);
    acc = new Text(Res.font.toFont(), this);
    update();
  }
  
  public var textWidth(get, never):Float;
  public var textHeight(get, never):Float;
  private inline function get_textWidth():Float { return acc.textWidth; }
  private inline function get_textHeight():Float { return acc.textHeight; }
  
  override function update() {
    var text:StringBuf = new StringBuf();
    
    for(reg in machine.registers)
    {
      text.add(reg.name.toUpperCase());
      text.add(": ");
      text.add(reg.value);
      text.add("\n");
    }
    for (port in machine.ports)
    {
      text.add(port.name);
      text.add(": ");
      text.add(Std.string(port.state).substr(0, 4));
      text.add("\n");
    }
    acc.text = text.toString();
  }
  
}