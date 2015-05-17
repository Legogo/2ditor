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
class AtlasBrowserSelector extends FlxSprite
{
  
  var size:Float = FlxG.width * 0.1; 
  
  public function new() 
  {
    super();
    
    scrollFactor.set();
    
    var lineStyle:Object = { color: FlxColor.RED, thickness: 2 };
    
    makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    FlxSpriteUtil.drawLine(this, 0, 0, size, 0, lineStyle);
    FlxSpriteUtil.drawLine(this, size, 0, size, size, lineStyle);
    FlxSpriteUtil.drawLine(this, 0, 0, 0, size, lineStyle);
    FlxSpriteUtil.drawLine(this, 0, size, size, size, lineStyle);
  }
  
  public function update_slotIndex(newIndex:Int):Void {
    x = (newIndex * size);
  }
  
}