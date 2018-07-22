package zachlang.exa;

import haxe.ds.Map;

class ExaHost
{
  public static var hostZero:ExaHost = new ExaHost("EXA_ZERO");
  public static var exaSpace:Array<ExaHost> = [hostZero];
  
  public var name:String;
  
  public var links:Map<Int, ExaHost>;
  
  public var exas:Array<ExaProto>;
  public var files:Array<ExaFile>;
  public var nodes:Array<ExaHardware>;
  
  // public var capacity:Int;
  
  public function new(name:String)
  {
    this.name = name;
    this.links = new Map();
    this.exas = new Array<ExaProto>();
    this.files = new Array<ExaFile>();
    this.nodes = new Array();
  }
  
  public inline function linkTo(index:Int, other:ExaHost)
  {
    this.links.set(index, other);
  }
  
  public inline function addExa(exa:ExaProto):Void
  {
    if (exas.indexOf(exa) == -1)
    {
      if (exa.host != null) exa.host.removeExa(exa);
      exas.push(exa);
      exa.host = this;
      for (node in nodes) exa.attach(node);
    }
  }
  
  public inline function removeExa(exa:ExaProto):Void
  {
    exas.remove(exa);
    for (node in nodes) exa.detach(node);
    exa.host = null;
  }
  
  public inline function addFile(file:ExaFile):Void
  {
    if (files.indexOf(file) == -1) this.files.push(file);
  }
  
  public inline function removeFile(file:ExaFile):Void
  {
    this.files.remove(file);
  }
  
  public function findFile(id:Int):ExaFile
  {
    for (f in files) if (f.id == id) return f;
    return null;
  }
  
}