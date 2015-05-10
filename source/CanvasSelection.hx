package;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import openfl.geom.Rectangle;
import openfl.utils.Object;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author 
 */
class CanvasSelection extends FlxGroup
{
  var start:FlxPoint = new FlxPoint();
  var size:FlxPoint = new FlxPoint();
  
  var rec:Rectangle = new Rectangle();
  var border:FlxSprite;
  var fill:FlxSprite;
  
  public function new() 
  {
    super();
    
    border = new FlxSprite();
    fill = new FlxSprite();
    
    add(border);
    add(fill);
    
    reset(new FlxPoint());
  }
  
  public function reset(startPos:FlxPoint):Void {
    start.x = startPos.x;
    start.y = startPos.y;
    
    size.x = 0;
    size.y = 0;
    
    rec.x = 0;
    rec.y = 0;
    rec.width = 0;
    rec.height = 0;
  }
  
  public function updateSelectionGraphic(newx:Int, newy:Int, w:Int, h:Int):Void {
    if (w <= 0 || h <= 0) {
      border.makeGraphic(0, 0);
      fill.makeGraphic(0, 0);
      return;
    }
    
    //border.makeGraphic(w, h);
    fill.makeGraphic(w, h);
    
    var lineStyle:Object = { color: FlxColor.GRAY, thickness: 1 };
    
    //FlxSpriteUtil.drawRect(border, 0, 0, w, h, FlxColor.WHITE, lineStyle);
    
    FlxSpriteUtil.drawRect(fill, 0, 0, w, h, FlxColor.WHITE);
    fill.alpha = 0.25;
    
    border.x = fill.x = newx;
    border.y = fill.y = newy;
    visible = true;
  }
  
  public function updateSelection(nextPosition:FlxPoint):Void {
    size.x = nextPosition.x - start.x;
    size.y = nextPosition.y - start.y;
    
    rec.x = (size.x < 0) ? start.x - Math.abs(size.x) : start.x;
    rec.y = (size.y < 0) ? start.y - Math.abs(size.y) : start.y;
    rec.width = Math.abs(size.x);
    rec.height = Math.abs(size.y);
    
    updateSelectionGraphic(Math.floor(rec.x), Math.floor(rec.y), Math.floor(rec.width), Math.floor(rec.height));
  }
  
  public function getRectangle():Rectangle { return rec; }
}