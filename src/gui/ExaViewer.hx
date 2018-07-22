package gui;

import zachlang.exa.ExaFile;
import hxd.Res;
import h2d.Text;
import h2d.Graphics;
import zachlang.core.HardwareModule;
import haxe.ds.Map;
import h2d.Sprite;
import zachlang.ExaSpace;
import zachlang.ExaProto;

class ExaViewer extends AppSprite
{
  
  private var space:ExaSpace;
  
  private var hardwares:Map<HardwareModule, Sprite>;
  private var files:Map<ExaFile, ExaFileViewer>;
  
  private var lx:Float;
  private var ly:Float;
  private var w:Int;
  private var h:Int;
  
  public function new(space:ExaSpace, parent:Sprite)
  {
    super(parent);
    this.space = space;
    hardwares = new Map();
    files = new Map();
    bg.lineStyle(1, 0xffffff);
    
    w = 100;
    h = 600;
    
    for (hw in space.hardwares)
    {
      var s:AppSprite = new AppSprite(this);
      hardwares.set(hw, s);
      var g:Graphics = new Graphics(s);
      var label:Text = new Text(Res.font.toFont(), s);
      label.text = Type.getClassName(Type.getClass(hw)).split(".").pop();
      label.x = 2;
      label.y = 4;
      var vis:RegisterView = new RegisterView(hw, s);
      vis.y = label.textHeight + 7;
      vis.x = 2;
      g.beginFill(0x333333);
      g.drawRect(0, 0, w, vis.y + vis.textHeight);
      if (Std.is(hw, ExaProto))
      {
        var v:TisModule = new TisModule(cast hw, this, -1, -1);
        lx = 300;//v.getSize().width + 5;
      }
    }
    
    var i:Int = 0;
    for(host in space.hosts)
    {
      bg.drawRect(lx + i * (w + 5) - 1, -1, w+2, h+2);
      var label:Text = new Text(Res.font.toFont(), this);
      bgHLine(lx + i * (w + 5), lx + (i + 1) * (w + 5)-5, label.textHeight);
      label.x = i * (w + 5) + lx;
      label.text = host.name;
      ly = label.textHeight + 1;
      i++;
    }
    this.x = 2;
    this.y = 2;
  }
  
  override function update() {
    
    var x:Int = 0;
    
    var y:Float = ly;
    inline function repos(s:Sprite)
    {
        s.x = lx + x * (w + 5);
        s.y = y;
        y += s.getSize().height + 2;
        y++;
    }
    
    var arr:Array<ExaFile> = new Array();
    inline function renderFile(file:ExaFile, held:Bool)
    {
      var view = files.get(file);
      if (view == null)
      {
        view = new ExaFileViewer(w, this);
        view.assign(file);
        files.set(file, view);
      }
      repos(view);
      view.setHeld(held);
      arr.push(file);
    }
    for (host in space.hosts)
    {
      y = ly;
      for (node in host.nodes)
      {
        repos(hardwares.get(node));
      }
      for (exa in host.exas)
      {
        repos(hardwares.get(exa));
        if (exa.file != null) renderFile(exa.file, true);
      }
      for (file in host.files)
      {
        renderFile(file, false);
      }
      x++;
    }
    for (f in files.keys())
    {
      if (arr.indexOf(f) == -1)
      {
        var s:ExaFileViewer = files.get(f);
        s.remove();
        files.remove(f);
      }
    }
    super.update();
  }
  
}

class ExaFileViewer extends AppSprite
{
  
  public var file:ExaFile;
  private var id:Text;
  private var content:Text;
  
  public function new(mx:Int, sprite:Sprite)
  {
    super(sprite);
    id = new Text(Res.font.toFont(), this);
    content = new Text(Res.font.toFont(), this);
    content.y = id.font.lineHeight;
    content.maxWidth = mx;
  }
  
  public function assign(file:ExaFile):Void
  {
    id.text = "#" + file.id;
    this.file = file;
    update();
  }
  
  public function setHeld(v:Bool):Void
  {
    if (v) id.text = "[#" + file.id + "]";
    else id.text = "#" + file.id;
  }
  
  override function update() {
    if (file != null)
    {
      var i:Int = 0;
      var str:StringBuf = new StringBuf();
      str.add("[");
      while (i < file.length)
      {
        if (i != 0) str.add(', ');
        if (file.tStorage[i] == 1) str.add(Std.string(file.iStorage[i]));
        else if (file.tStorage[i] == 2) str.add("'" + file.kStorage[i] + "'");
        else str.add("NULL");
        i++;
      }
      str.add("]");
      content.text = str.toString();
    }
    super.update();
  }
  
}