package zachlang;

import zachlang.exa.ExaFile;
import zachlang.exa.ExaHost;
import zachlang.core.HardwareModule;
import zachlang.exa.custom.FileIndexer;

class ExaSpace
{
  public var hardwares:Array<HardwareModule>;
  public var paused:Bool;
  public var error:HardwareError;
  
  public var hosts:Map<String, ExaHost>;
  
  public function new()
  {
    hardwares = new Array();
    hosts = new Map();
  }
  
  public function fromJson(data:JsonSpace):Void
  {
    for (hostDef in data.hosts)
    {
      var host:ExaHost = new ExaHost(hostDef.name);
      hosts.set(host.name, host);
    }
    
    for (link in data.link)
    {
      var first = link[0].split("@");
      var second = link[1].split("@");
      var hostA:ExaHost = hosts.get(first[0]);
      var hostB:ExaHost = hosts.get(second[0]);
      if (hostA == null || hostB == null) continue;
      hostA.linkTo(Std.parseInt(first[1]), hostB);
      hostB.linkTo(Std.parseInt(second[1]), hostA);
    }
    
    for (info in data.data)
    {
      var host:ExaHost = hosts.get(info.host);
      if (host == null) continue;
      switch(info.type)
      {
        case "file":
          var f:ExaFile = new ExaFile(info.id);
          if (info.data != null)
          {
            var arr:Array<Dynamic> = info.data;
            for (val in arr)
            {
              if (Std.is(val, String)) f.writeKeyword(val);
              else f.writeInteger(val);
            }
          }
          host.addFile(f);
        case "file_indexer":
          var indexer:FileIndexer = new FileIndexer();
          host.nodes.push(indexer);
          addHardware(indexer);
      }
    }
    for (info in data.data)
    {
      if (info.type == "exa")
      {
        var host:ExaHost = hosts.get(info.host);
        if (host == null) continue;
        var exa:ExaProto = new ExaProto();
        if (info.data != null)
        {
          exa.compile(info.data);
        }
        host.addExa(exa);
        addHardware(exa);
      }
      
    }
  }
  
  public function addHardware(hw:HardwareModule):Void
  {
    hardwares.push(hw);
    hw.reset();
  }
  
  public function reset():Void
  {
    for (hw in hardwares) hw.reset();
  }
  
  public function update():Void
  {
    if (paused) return;
    error = null;
    var interrupt:HardwareModule = null;
    var asleep:Int = 0;
    
    for (hw in hardwares)
    {
      try
      {
        hw.step();
      }
      catch(e:HardwareError)
      {
        error = e;
        error.hardware = hw;
        interrupt = hw;
      }
    }
    
    for (hw in hardwares)
    {
      try
      {
        hw.flushWrites();
      }
      catch (e:HardwareError)
      {
        error = e;
        error.hardware = hw;
        interrupt = hw;
      }
    }
    if (interrupt != null)
    {
      trace(interrupt);
      trace(error);
      pause();
    }
  }
  
  public function pause()
  {
    paused = true;
  }
  
  public function resume()
  {
    paused = false;
  }
}

typedef JsonSpace =
{
  var hosts:Array<JsonHost>;
  var link:Array<Array<String>>;
  var data:Array<JsonHW>;
}

typedef JsonHost =
{
  var name:String;
  var capacity:Int;
}

typedef JsonHW = 
{
  var type:String;
  var id:Int;
  var data:Dynamic;
  var host:String;
}