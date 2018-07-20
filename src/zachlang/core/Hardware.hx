package zachlang.core;

import haxe.ds.Map;

class Hardware<EX> extends HardwareModule
{
  public var name:String;
  
  public var labels:Map<String, Int>;
  
  public var program:Array<Expr<EX>>;
  public var position:Int;
  
  public var source:String;
  private var jumped:Bool;
  
  
  private function new(name:String)
  {
    super();
    this.name = name;
    this.labels = new Map();
  }
  
  public function compile(source:String):Void
  {
    throw "Not implemented";
  }
  
  public function goToLabel(label:String):Void
  {
    if (program == null) throw "No program compiled on this hardware!";
    var idx:Int = labels.get(label);
    if (idx == -1) throw "Undefined label: " + label;
    var i:Int = 0;
    while (i < program.length)
    {
      if (program[i].line >= idx)
      {
        position = i;
        jumped = true;
        nextInsutrction();
        return;
      }
      i++;
    }
    throw "Label is out of program bounds!";
  }
  
  public function jump(distance:Int):Void
  {
    position += distance;
    if (position < 0) position = 0;
    else if (position >= program.length) position = program.length - 1;
    jumped = true;
    nextInsutrction();
  }
  
  override public function reset():Void
  {
    position = 0;
    super.reset();
  }
  
  override public function step():Void
  {
    var e:Expr<EX> = program[position];
    
    blocked = false;
    execute(e);
    if (!blocked)
    {
      if (!jumped) nextInsutrction();
      else jumped = false;
      
      if (program[position].breakpoint) runtimeError("Debug breakpoint");
    }
  }
  
  private function nextInsutrction()
  {
    position++;
    if (position == program.length) position = 0;
  }
  
  private function execute(e:Expr<EX>):Void
  {
    
  }
  
  override function runtimeError(message:String):HardwareError {
    return new HardwareError(message, program[position].line, HardwareErrorType.Runtime);
  }
  
}