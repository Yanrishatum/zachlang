package zachlang.tis;

enum TisExpr
{
  Nop;
  Swp;
  Sav;
  Neg;
  Mov(src:RegisterType, dst:RegisterType);
  Add(src:RegisterType);
  Sub(src:RegisterType);
  Jmp(label:String);
  Jez(label:String);
  Jnz(label:String);
  Jlz(label:String);
  Jgz(label:String);
  Jro(src:RegisterType);
}
