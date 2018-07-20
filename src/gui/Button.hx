package gui;

import hxd.Event;
import hxd.Cursor;
import h2d.Graphics;
import h2d.Text;
import hxd.Res;
import h2d.Font;
import h2d.Sprite;
import h2d.Interactive;

class Button extends Interactive
{
  private var text:Text;
  private var bg:Graphics;
  
  public function new(label:String, parent:Sprite)
  {
    var fnt:Font = Res.font.toFont();
    text = new Text(fnt);
    text.text = label;
    text.x = 2;
    text.y = 2;
    super(text.textWidth + 4, text.textHeight + 4, parent);
    
    bg = new Graphics(this);
    bg.lineStyle(1, 0xffffff);
    bg.drawRect(0, 0, width, height);
    bg.endFill();
    
    addChild(text);
    
    cursor = Cursor.Button;
    
  }
  
  override function onPush(e:Event) {
    bg.y = 1;
    text.y = 3;
  }
  
  override function onRelease(e:Event) {
    bg.y = 0;
    text.y = 2;
  }
}