package zachlang.exa.custom;

import zachlang.registers.PortState;
import zachlang.exa.ExaHardware;

class FileIndexer extends ExaHardware
{
  
  private var port:Port;
  
  public function new()
  {
    super();
    addRegister(port = new Port("index", false, true));
    port.state = PortState.Read;
  }
  
  override function reset() {
    super.reset();
    port.state = PortState.Read;
  }
  
  
  
  override function onReadResolved(local:Port, by:Port) {
    local.read();
    var exa:ExaProto = cast by.module;
    exa.file.id = local.value;
    port.state = PortState.Read;
  }
  
}