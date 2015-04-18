package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import openfl.utils.Object;

/**
 * ...
 * @author 
 */
class CanvasGrid extends CanvasObject
{
  var gridSpacing:Float = 50;
  var offset:FlxPoint = new FlxPoint();
  var offsetDiff:FlxPoint = new FlxPoint();
  
  public function new() 
  {
    super(new FlxSprite());
    name = "grid";
    changeGridSize(gridSpacing);
    
    //BaseState.root.add(spr);
    spr.scrollFactor.set();
  }
  
  public function changeGridSize(newSize:Float):Void {
    gridSpacing = newSize;
    
    //spr.makeGraphic(10, SystemInfo.HEIGHT);
    //spr.makeGraphic(SystemInfo.WIDTH, 10);
  }
  
  override public function update():Void 
  {
    super.update();
    /*
    spr.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    
    offsetDiff.x = Math.abs(offset.x) % gridSpacing;
    offsetDiff.y = Math.abs(offset.y) % gridSpacing;
    
    //trace(offsetDiff.x, offsetDiff.y);
    
    var idx:Int = 0;
    var i:Int = 0;
    //trace(i + " -> " + FlxG.width);
    
    while (i < FlxG.width / gridSpacing) {
      idx = Math.floor((i * gridSpacing) + offsetDiff.y);
      FlxSpriteUtil.drawLine(spr, 0, idx, FlxG.width, idx, lineStyle);
      i++;
    }
    
    i = 0;
    while (i < FlxG.width / gridSpacing) {
      idx = Math.floor((i * gridSpacing) + offsetDiff.x);
      FlxSpriteUtil.drawLine(spr, idx, 0, idx, FlxG.height, lineStyle);
      i++;
    }
    */
  }
}