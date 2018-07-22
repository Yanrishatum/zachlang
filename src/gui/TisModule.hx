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
  
  // private var acc:Text;
  private var src:Text;
  private var caret:Graphics;
  private var caretStep:Float;
  private var offsetTop:Float;
  private var registers:RegisterView;
  
  public var machine:Hardware<Any>;
  public function new(machine:Hardware<Any>, s2d:Sprite, x:Float = 10, y:Float = 10)
  {
    this.machine = machine;
    super(s2d);
    
    caret = new Graphics(this);
    
    var fnt:Font = Res.font.toFont();
    offsetTop = fnt.lineHeight;
    
    label(machine.name, 2, 1);
    
    src = label(machine.source, 2, offsetTop + 2);
    
    var srcW = Math.max(src.textWidth, 100);
    
    registers = new RegisterView(machine, this);
    registers.x = srcW + 5 + 2;
    registers.y = offsetTop + 2;
    // acc = label(null, srcW + 5 + 2, offsetTop + 2);
    
    caretStep = fnt.lineHeight;
    caret.beginFill(0xEEEEEE, 0.2);
    caret.drawRect(0, 0, srcW + 4, caretStep);
    caret.endFill();
    
    update();
    redrawBG();
    this.x = x;
    this.y = y;
  }
  
  private function redrawBG():Void
  {
    bg.clear();
    bg.lineStyle(1,0xFFFFFF, 1);
    var w = registers.x + 2 + Math.max(registers.acc.calcTextWidth("REG: -999"), registers.textWidth);
    bg.drawRect(0, 0, w, Math.max(src.textHeight, registers.textHeight) + 4 + offsetTop);
    bgVLine(registers.x - 3, offsetTop, Math.max(src.textHeight, registers.textHeight) + 4 + offsetTop);
    bgHLine(0, w, offsetTop);
    bg.endFill();
    
  }
  
  override function update() {
    var text:StringBuf = new StringBuf();
    if (src.text != machine.source)
    {
      src.text = machine.source;
      redrawBG();
      registers.x = Math.max(src.textWidth, 100) +5 + 2;
    }
    
    caret.y = machine.program[machine.position].line * caretStep + offsetTop;
    super.update();
  }
  
}