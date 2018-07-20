package gui;

import zachlang.core.Hardware;
import h2d.Graphics;
import h2d.Font;
import hxd.Res;
import hxd.res.Resource;
import h2d.Text;
import h2d.RenderContext;
import h2d.Sprite;
import h2d.Scene;
import zachlang.TIS100;

class TisModule extends AppSprite
{
  
  private var acc:Text;
  private var src:Text;
  private var caret:Graphics;
  private var caretStep:Float;
  private var offsetTop:Float;
  
  public var machine:Hardware<Any>;
  public function new(machine:Hardware<Any>, s2d:Scene, x:Float = 10, y:Float = 10)
  {
    this.machine = machine;
    super(s2d);
    
    caret = new Graphics(this);
    
    var fnt:Font = Res.font.toFont();
    offsetTop = fnt.lineHeight;
    
    label(machine.name, 2, 1);
    
    src = label(machine.source, 2, offsetTop + 2);
    
    var srcW = Math.max(src.textWidth, 100);
    
    acc = label(null, srcW + 5 + 2, offsetTop + 2);
    
    caretStep = fnt.lineHeight;
    caret.beginFill(0xEEEEEE, 0.2);
    caret.drawRect(0, 0, srcW + 4, caretStep);
    caret.endFill();
    
    update();
    var w = acc.x + 2 + Math.max(acc.calcTextWidth("REG: -999"), acc.textWidth);
    
    bg.lineStyle(1,0xFFFFFF, 1);
    bg.drawRect(0, 0, w, Math.max(src.textHeight, acc.textHeight) + 4 + offsetTop);
    bgVLine(acc.x - 3, offsetTop, Math.max(src.textHeight, acc.textHeight) + 4 + offsetTop);
    bgHLine(0, w, offsetTop);
    bg.endFill();
    
    this.x = x;
    this.y = y;
  }
  
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
    
    caret.y = machine.program[machine.position].line * caretStep + offsetTop;
  }
  
}