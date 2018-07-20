package zachlang.tis;

enum TisToken
{
  TId(str:String);
  TInt(i:Int);
  TNegate;
  TLabel(name:String);
  TEof;
  TBreakpoint;
}
