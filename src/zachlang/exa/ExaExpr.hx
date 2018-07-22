package zachlang.exa;

enum ExaExpr
{
  // Value manipulation
  Copy(src:RegisterType, dst:RegisterType);
  AddI(srcA:RegisterType, srcB:RegisterType, dst:RegisterType);
  SubI(srcA:RegisterType, srcB:RegisterType, dst:RegisterType);
  MulI(srcA:RegisterType, srcB:RegisterType, dst:RegisterType);
  DivI(srcA:RegisterType, srcB:RegisterType, dst:RegisterType);
  ModI(srcA:RegisterType, srcB:RegisterType, dst:RegisterType);
  Swizz(src:RegisterType, order:RegisterType, dst:RegisterType);
  
  // Branching
  //mark(label)
  Jump(label:String);
  TJump(label:String);
  FJump(label:String);
  
  // Testing
  Test(left:RegisterType, right:RegisterType, op:ExaTestOp);
  
  // Lifecycle
  Repl(label:String);
  Halt;
  Kill;
  
  // Movement
  Link(src:RegisterType);
  Host(dst:RegisterType);
  
  // Communication
  Mode;
  Void(dst:RegisterType); // Void(M) : Read+Discard / Void(F) : Remove
  TestMrd;
  //Test(VSpecial("MRD");
  
  // Files
  Make;
  Grab(src:RegisterType);
  File(dst:RegisterType);
  Seek(src:RegisterType);
  //Void(F)
  Drop;
  Wipe;
  TestEof;
  //Test(VSpecial("EOF"));
  
  // Misc
  //Note
  Noop;
  Rand(min:RegisterType, max:RegisterType, dst:RegisterType);
}
