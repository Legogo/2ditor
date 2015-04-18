package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Rectangle;
import openfl.utils.Object;

/**
 * ...
 * @author 
 */
class CanvasObject extends FlxGroup
{
  
  var lineStyle:Object = { color: FlxColor.CYAN, thickness: 5 };
  var visual_selection:FlxSprite;
  
  var debug_info:FlxText;
  public var spr:FlxSprite;
  
  public var staticObject:Bool = false;
  
  public var name:String = "";
  var clickPosition:FlxPoint = new FlxPoint();
  var bounds:Rectangle = new Rectangle();
  
  public function new(sprite:FlxSprite) 
  {
    super();
    debug_info = new FlxText(0, 0, 100);
    spr = sprite;
    
    add(spr);
    add(debug_info);
    
    visual_selection = new FlxSprite();
    drawSelectionLayer();
    add(visual_selection);
    
    unselect();
    
    Layers.getLayer(Layers.LAYER_DEBUG).add(debug_info);
  }
  
  function drawSelectionLayer():Void {
    var lineLenght:Int = 10;
    visual_selection.makeGraphic(Math.floor(spr.width),Math.floor(spr.height),FlxColor.TRANSPARENT,true);
    FlxSpriteUtil.drawLine(visual_selection, 0, 0, 0, lineLenght, lineStyle);
    FlxSpriteUtil.drawLine(visual_selection, 0, 0, lineLenght, 0, lineStyle);
    
    FlxSpriteUtil.drawLine(visual_selection, spr.width, spr.height, spr.width - lineLenght, spr.height, lineStyle);
    FlxSpriteUtil.drawLine(visual_selection, spr.width, spr.height, spr.width, spr.height - lineLenght, lineStyle);
  }
  
  override public function update():Void 
  {
    super.update();
    
    visual_selection.x = spr.x;
    visual_selection.y = spr.y;
    
    if (debug_info.visible) {
      update_position();
    }
  }
  
  public function update_camera(delta:FlxPoint):Void {
    spr.x += delta.x;
    spr.y += delta.y;
  }
  
  function update_position():Void {
    if (FlxG.mouse.pressed) {
      var pt:FlxPoint = FlxG.mouse.getWorldPosition();
      spr.x = pt.x - clickPosition.x;
      spr.y = pt.y - clickPosition.y;
      updateInfo();
      //trace("update_position");
    }
  }
  
  public function select():Void {
    var pt:FlxPoint = FlxG.mouse.getWorldPosition();
    clickPosition.x = pt.x - spr.x;
    clickPosition.y = pt.y - spr.y;
    debug_info.visible = true;
    
    trace(name + " selected (at "+clickPosition+")");
  }
  public function unselect():Void {
    clickPosition.x = clickPosition.y = -1;
    debug_info.visible = false;
    
    trace(name + " unselected");
  }
  
  function updateInfo():Void {
    debug_info.text = spr.x + "," + spr.y;
    debug_info.x = spr.x;
    debug_info.y = spr.y;
  }
  
  public function getBounds():Rectangle {
    bounds.x = spr.x;
    bounds.y = spr.y;
    bounds.width = spr.width;
    bounds.height = spr.height;
    return bounds;
  }
  
  public function show():Void { spr.visible = true; }
  public function hide():Void { spr.visible = false; }
  public function setVisible(flag:Bool):Void { spr.visible = flag; }
}