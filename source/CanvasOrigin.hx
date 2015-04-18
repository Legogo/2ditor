package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.utils.Object;

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
    
    lineStyle = { color: FlxColor.RED, thickness: 3 };
    
    spr.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    FlxSpriteUtil.drawLine(spr, 0, 5, 10, 5, lineStyle);
    FlxSpriteUtil.drawLine(spr, 5, 0, 5, 10, lineStyle);
    spr.x = -5;
    spr.y = -5;
  }
  
}