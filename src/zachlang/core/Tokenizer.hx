package zachlang.core;

import haxe.io.Input;

class Tokenizer<TK, EX>
{
  
  private var input:Input;
  
  private var separators:Array<String>;
  private var char:Int = -1;
  private var line:Int;
  private var hw:Hardware<EX>;
  
  public function new()
  {
    
  }
  
  public function tokenize(hw:Hardware<EX>, input:Input):Array<Expr<EX>>
  {
    throw "Not implemented";
  }
  
  private inline function assign(hw:Hardware<EX>, input:Input):Void
  {
    this.hw = hw;
    this.input = input;
    this.char = -1;
    this.line = 0;
  }
  
  private inline function readChar()
  {
    return try { input.readByte(); } catch (e:Dynamic) 0;
  }
  
  private function token():TK
  {
    throw "Not implemented";
  }
  
  private inline function makeExpr(e:EX, isBreakpoint:Bool = false, meta:Int = 0):Expr<EX>
  {
    return {
      e: e,
      breakpoint: isBreakpoint,
      meta: meta,
      line: line
    }
  }
  
}