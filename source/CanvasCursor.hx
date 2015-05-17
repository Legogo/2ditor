package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;

/**
 * ...
 * @author 
 */
class CanvasCursor extends FlxSprite
{
  
  public var lastPosition:FlxPoint = new FlxPoint();
  public var delta:FlxPoint = new FlxPoint(); // diff each frame
  
  public var left_mouseOrigin:FlxPoint = new FlxPoint();
  public var left_lastPosition:FlxPoint = new FlxPoint();
  public var left_mouseMoved:Bool = false;
  public var left_mouseShift:FlxPoint = new FlxPoint(); // diff from origin
  
  public function new() 
  {
    super();
  }
  
  override public function update():Void 
  {
    super.update();
    
		var pos:FlxPoint = FlxG.mouse.getWorldPosition();
		
    delta.x = pos.x - lastPosition.x;
    delta.y = pos.y - lastPosition.y;
    
    lastPosition = pos;
    
		if (FlxG.mouse.justReleased) {
			left_mouseShift.x = left_mouseShift.y = 0;
			left_lastPosition.x = left_lastPosition.y = 0;
			return;
		}
		
    if (FlxG.mouse.justPressed) {
      left_lastPosition.x = pos.x;
      left_lastPosition.y = pos.y;
      
      left_mouseOrigin.x = pos.x;
      left_mouseOrigin.y = pos.y;
      left_mouseMoved = false;
      //trace("origin = " + mouseOrigin);
    }
    
		if (FlxG.mouse.pressed) {
			left_mouseShift.x = pos.x - left_lastPosition.x;
			left_mouseShift.y = pos.y - left_lastPosition.y;
      left_lastPosition.x = pos.x;
      left_lastPosition.y = pos.y;
      
      if (!isMouseNearClickOrigin()) {
        if (!left_mouseMoved) {
          left_mouseMoved = true;
          trace("<Canvas> mouse moved");
        }
      }
		}
		
  }
  
  function isMouseNearClickOrigin():Bool {
    var dist:Float = FlxMath.getDistance(left_mouseOrigin, FlxG.mouse.getWorldPosition());
    //trace("distance ? " + dist+" (origin ? "+mouseOrigin+")");
    if (dist < 5) {
      return true;
    }
    return false;
  }
  
}