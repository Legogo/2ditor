package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Object;

/**
 * ...
 * @author 
 */
class CanvasGrid extends CanvasObject
{
  var gridSpacing:Float = 160; // 128 + 32
  var offset:FlxPoint = new FlxPoint();
  var offsetDiff:FlxPoint = new FlxPoint();
  
  var gridSize:Rectangle = new Rectangle();
  
  public function new(c:Canvas) 
  {
    super(c, new FlxSprite());
    name = "grid";
    changeGridSize(gridSpacing);
    
    //BaseState.root.add(spr);
    spr.scrollFactor.set();
    
    toggle();
  }
  
  public function changeGridSize(newSize:Float):Void {
    gridSpacing = newSize;
    
    lineStyle.thickness = 1;
    lineStyle.color = 0x55dd0000;
    
    //spr.makeGraphic(10, SystemInfo.HEIGHT);
    //spr.makeGraphic(SystemInfo.WIDTH, 10);
    
    gridSize.width = FlxG.width * 3;
    gridSize.height = FlxG.height * 3;
    
    drawGrid();
  }
  
  public function drawGrid():Void {
    spr.makeGraphic(Math.floor(gridSize.width), Math.floor(gridSize.height), FlxColor.TRANSPARENT, true);
    
    offsetDiff.x = Math.abs(offset.x) % gridSpacing;
    offsetDiff.y = Math.abs(offset.y) % gridSpacing;
    
    //trace(offsetDiff.x, offsetDiff.y);
    
    var idx:Int = 0;
    var i:Int = 0;
    //trace(i + " -> " + FlxG.width);
    
    while (i < gridSize.width / gridSpacing) {
      idx = Math.floor((i * gridSpacing) + offsetDiff.y);
      FlxSpriteUtil.drawLine(spr, 0, idx, gridSize.width * 2, idx, lineStyle);
      i++;
    }
    
    i = 0;
    while (i < gridSize.height / gridSpacing) {
      idx = Math.floor((i * gridSpacing) + offsetDiff.x);
      FlxSpriteUtil.drawLine(spr, idx, 0, idx, gridSize.height * 2, lineStyle);
      i++;
    }
  }
  
  public function toggle():Void {
    visible = !visible;
  }
  
  public function snapPosition(pt:FlxPoint):FlxPoint {
    pt.x = Math.floor(pt.x / gridSpacing) * gridSpacing;
    pt.y = Math.floor(pt.y / gridSpacing) * gridSpacing;
    return pt;
  }
}