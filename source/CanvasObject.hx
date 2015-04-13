package;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * ...
 * @author 
 */
class CanvasObject
{
  public var staticObject:Bool = false;
  public var x:Float = 0;
  public var y:Float = 0;
  
  public var spr:FlxSprite;
  
  public function new(sprite:FlxSprite) 
  {
    spr = sprite;
  }
  
  public function update_position(origin:FlxPoint):Void {
    spr.x = x + origin.x;
    spr.y = y + origin.y;
  }
  
  public function move(pt:FlxPoint):Void {
    x += pt.x;
    y += pt.y;
    
    //x = Math.max(x, 0);
    //y = Math.max(y, 0);
  }
}