package zachlang.exa;

enum ExaToken
{
  TId(str:String);
  TInt(i:Int);
  TMinus;
  TEof;
  TBreakpoint;
  TOp(op:ExaTestOp);
  TKeyword(str:String);
}