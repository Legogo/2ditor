package;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.util.FlxPoint;
import openfl.geom.Point;

/**
 * ...
 * @author 
 */
class UiButton extends FlxSprite
{
  
  public var name:String = "";
  var eventClick:Void->Void;
  
  public function new(asset:Dynamic, onClick:Void->Void ) 
  {
    super();
    loadGraphic(asset);
    
    eventClick = onClick;
  }
  
  override public function update():Void 
  {
    super.update();
    
    if (FlxG.mouse.justReleased) {
      
      var pt:FlxPoint = FlxG.mouse.getWorldPosition();
      if (pt.x > x && pt.x < x + width) {
        if (pt.y > y && pt.y < y + height) {
          
          trace("<Button> clicked " + name);
          if (eventClick != null) {
            eventClick();
          }
          
        }
      }
    }
  }
}