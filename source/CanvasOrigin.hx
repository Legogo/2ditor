package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author 
 */
class CanvasOrigin extends CanvasObject
{

  public function new() 
  {
    super(new FlxSprite());
    staticObject = true;
    
    spr.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    FlxSpriteUtil.drawLine(spr, 0, 5, 10, 5, { color: FlxColor.RED, thickness: 3 } );
    FlxSpriteUtil.drawLine(spr, 5, 0, 5, 10, { color: FlxColor.RED, thickness: 3 } );
    
    x = -5;
    y = -5;
  }
  
}