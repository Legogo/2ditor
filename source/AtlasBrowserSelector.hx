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
class AtlasBrowserSelector extends CanvasObject
{
  
  var size:Float = FlxG.width * 0.1; 
  var lineStyle:Object = { color: FlxColor.RED, thickness: 5 };
  
  public function new() 
  {
    super(new FlxSprite());
    staticObject = true;
    spr.scrollFactor.set();
    
    spr.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    FlxSpriteUtil.drawLine(spr, 0, 0, size, 0, lineStyle);
    FlxSpriteUtil.drawLine(spr, size, 0, size, size, lineStyle);
    FlxSpriteUtil.drawLine(spr, 0, 0, 0, size, lineStyle);
    FlxSpriteUtil.drawLine(spr, 0, size, size, size, lineStyle);
  }
  
  public function update_slotIndex(newIndex:Int):Void {
    spr.x = (newIndex * size);
  }
}