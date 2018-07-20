package gui;

import hxd.Res;
import h2d.Font;
import h2d.TextInput;
import h2d.Graphics;
import h2d.Sprite;
import zachlang.custom.NumberInput;

class NumModule extends AppSprite
{
  
  private var txt:TextInput;
  
  public function new(module:NumberInput, parent:Sprite, x:Float = 0, y:Float = 0)
  {
    super(parent);
    
    var fnt:Font = Res.font.toFont();
    label("Number input", 2, 1);
    var base:Float = fnt.lineHeight;
    txt = new TextInput(fnt, this);
    txt.x = 2;
    txt.y = base + 2;
    txt.inputWidth = 100;
    
    var btn:Button = new Button("Send", this);
    btn.onClick = function(e:hxd.Event) {
      module.send(Std.parseInt(txt.text));
    }
    btn.x = 104;
    btn.y = base;
    
    bg.lineStyle(1,0xFFFFFF, 1);
    bg.drawRect(0, 0, 104 + btn.width, base + btn.height);
    bgHLine(0, 104 + btn.width, base);
    bg.endFill();
    // bg.moveTo(acc.x - 3, offsetTop);
    // bg.lineTo(acc.x - 3, src.textHeight + 4 + offsetTop);
    // bg.moveTo(0, offsetTop);
    // bg.lineTo(w, offsetTop);
    // bg.endFill();
    
    this.x = x;
    this.y = y;
    
    var view:RegisterView = new RegisterView(module, this);
    view.y = base + btn.height;
  }
  
}