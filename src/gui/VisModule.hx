package gui;

import h3d.mat.Data.TextureFormat;
import h3d.mat.Texture;
import h2d.Tile;
import h2d.Bitmap;
import h2d.RenderContext;
import haxe.io.Bytes;
import hxd.BitmapData;
import h2d.Sprite;
import zachlang.tis.VisualizationModule;

class VisModule extends AppSprite
{
  private var bitmap:BitmapData;
  private var module:VisualizationModule;
  private var texture:Texture;
  private var tile:Tile;
  
  public function new(module:VisualizationModule, parent:Sprite, x:Float = 0, y:Float = 0)
  {
    super(parent);
    this.module = module;
    module.onChange = redraw;
    if (module.width != 0) redraw();
    this.x = x;
    this.y = y;
    // var view = new RegisterView(module, this);
    // view.x = 100;
  }
  
  private function redraw():Void
  {
    if (bitmap == null || bitmap.width != module.width || bitmap.height != module.height)
    {
      var scale = 4;
      if (bitmap != null)
      {
        bitmap.dispose();
        texture.resize(bitmap.width, bitmap.height);
        tile.setSize(module.width, module.height);
      }
      else 
      {
        texture = new Texture(module.width, module.height);
        tile = new Tile(texture, 0, 0, module.width, module.height);
        var btm:Bitmap = new Bitmap(tile, this);
        btm.setPos(1, 1);
        btm.scale(scale);
      }
      bitmap = new BitmapData(module.width, module.height);
      bg.clear();
      bg.lineStyle(1, 0xffffff);
      bg.drawRect(0, 0, module.width * scale + 2, module.height * scale + 2);
      bg.endFill();
    }
    var x:Int = 0, y:Int = 0;
    var i:Int = 0;
    var bytes:Bytes = module.matrix;
    bitmap.lock();
    while (i < bytes.length)
    {
      bitmap.setPixel(x, y, 0xff000000 | module.palette[bytes.get(i)]);
      i++;
      if (++x == module.width) { x = 0; y++; }
    }
    bitmap.unlock();
    texture.uploadBitmap(bitmap);
  }
  
}