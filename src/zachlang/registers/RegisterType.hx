package zachlang.registers;

enum RegisterType
{
  VRegister(reg:Register);
  VPort(port:Port);
  VValue(value:Int);
  VSpecial(type:String);
}
