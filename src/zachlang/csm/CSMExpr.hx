package zachlang.csm;

enum CSMExpr
{
  // Basic
  Nop;
  Mov(src:RegisterType, dst:RegisterType);
  Jmp(label:String);
  Slp(time:RegisterType);
  Slx(port:Port);
  
  // Math
  Add(src:RegisterType);
  Sub(src:RegisterType);
  Mul(src:RegisterType);
  Not;
  Dgt(pos:RegisterType);
  Dst(pos:RegisterType, val:RegisterType);
  
  // Test
  Teq(left:RegisterType, right:RegisterType);
  Tgt(left:RegisterType, right:RegisterType);
  Tlt(left:RegisterType, right:RegisterType);
  Tcp(left:RegisterType, right:RegisterType);
}