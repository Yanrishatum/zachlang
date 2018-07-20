package gui;

import hxd.Res;
import h2d.Text;
import h2d.Graphics;

class AppSprite extends h2d.Sprite
{
  private var bg:Graphics;
  
  public function new(?parent:h2d.Sprite)
  {
    super(parent);
    bg = new Graphics(this);
  }
  
  private function label(text:String, x:Float, y:Float):Text
  {
    var txt:Text = new Text(Res.font.toFont(), this);
    if (text != null) txt.text = text;
    txt.textColor = 0xffffff;
    txt.x = x;
    txt.y = y;
    return txt;
  }
  
  private inline function bgHLine(x0:Float, x1:Float, y:Float):Void
  {
    bg.moveTo(x0, y);
    bg.lineTo(x1, y);
  }
  
  private inline function bgVLine(x:Float, y0:Float, y1:Float):Void
  {
    bg.moveTo(x, y0);
    bg.lineTo(x, y1);
  }
  
  private inline function bgLine(x0:Float, y0:Float, x1:Float, y1:Float):Void
  {
    bg.moveTo(x0, y0);
    bg.lineTo(x1, y1);
  }
  
  public function update()
  {
    for (child in children)
    {
      if (Std.is(child, AppSprite)) cast(child, AppSprite).update();
    }
  }
  
}