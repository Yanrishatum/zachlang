package zachlang.registers;

enum PortState
{
  Idle;
  Listen;
  Writing;
  Write;
  WriteDone;
  Read;
}