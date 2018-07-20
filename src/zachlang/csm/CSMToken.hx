package zachlang.csm;

enum CSMToken
{
  TId(str:String);
  TInt(i:Int);
  TLabel(name:String);
  TEof;
  TBreakpoint;
  TInitializer;
  TPlus;
  TMinus;
}
