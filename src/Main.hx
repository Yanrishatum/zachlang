package;

import h3d.mat.TextureChannels;
import zachlang.tis.VisualizationModule;
import hxd.Key;
import zachlang.custom.NumberInput;
import hxd.Timer;
import hxd.Res;
import hxd.res.Any;
import hxd.res.Resource;
import zachlang.TIS100;
import h2d.Bitmap;
import zachlang.ZachPC;
import gui.TisModule;
import gui.AppSprite;
import zachlang.ChengShangMicro;
import gui.NumModule;
import gui.VisModule;
import zachlang.ExaProto;

class Main extends hxd.App
{
  public static var pc:ZachPC;
  
  private var sprites:Array<AppSprite>;
  
  override function init() {
    sprites = new Array();
    
    pc = new ZachPC();
    var tis:TIS100 = new TIS100();
    var sz:ChengShangMicro = new ChengShangMicro();
    var vis:VisualizationModule = new VisualizationModule();
    var exa:ExaProto = new ExaProto();
    
    tis.compile(Res.program.entry.getText());
    sz.compile(Res.shenzhen.entry.getText());
    exa.compile(Res.exa.entry.getText());
    
    pc.addHardware(tis);
    pc.addHardware(sz);
    pc.addHardware(vis);
    pc.addHardware(exa);
    
    tis.connectPort(tis.ports.get("right"), sz.ports.get("x0"));
    vis.init(36, 22);
    vis.palette = [0, 0xDEEED6, 0xD04648, 0x597DCE, 0x6DAA2C];
    sz.connectPort(sz.ports.get("x1"), vis.ports.get("in"));
    
    sprites.push(new TisModule(cast tis, s2d));
    sprites.push(new TisModule(cast sz, s2d, 200));
    sprites.push(new VisModule(vis, s2d, 20, 140));
    sprites.push(new TisModule(cast exa, s2d, 400));
  }
  
  private var updateFrame:Int = 0;
  private var running:Bool = true;
  
  override function update(dt:Float) {
    updateFrame++;
    if (Key.isPressed(Key.SPACE))
    {
      pc.update();
      for (s in sprites) s.update();
    }
    if (Key.isReleased(Key.Z)) running = !running;
    if (Key.isReleased(Key.R)) pc.reset();
    if (running && updateFrame > -1)
    {
      updateFrame = 0;
      pc.update();
      if (pc.paused)
      {
        running = false;
        pc.resume();
      }
    }
    for (s in sprites) s.update();
  }
  
  static function main() {
    #if js
    hxd.Res.initEmbed());
    #else
    hxd.Res.initLocal();
    #end
    new Main();
  }
}
