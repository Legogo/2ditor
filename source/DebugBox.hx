package;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author 
 */
class DebugBox extends FlxGroup
{
  static private var instance:DebugBox;
	public var tf:FlxText;
  
  public function new() 
  {
    super();
    instance = this;
    tf = new FlxText(0, 0, 500, "---");
    add(tf);
    
    Layers.getLayer(Layers.LAYER_DEBUG).add(this);
  }
  
  static public function log(s:String):Void {
    instance.tf.text += "\n" + s;
  }
}