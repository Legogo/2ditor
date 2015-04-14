package;
import flixel.animation.FlxPrerotatedAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxPoint;

/**
 * ...
 * @author 
 */
class CanvasObject extends FlxGroup
{
  public var info:FlxText;
  public var spr:FlxSprite;
  
  public var staticObject:Bool = false;
  
  var name:String = "";
  var clickPosition:FlxPoint = new FlxPoint();
  
  public function new(sprite:FlxSprite) 
  {
    super();
    info = new FlxText(0, 0, 100);
    spr = sprite;
    
    add(spr);
    add(info);
    
    //Layers.getLayer(Layers.LAYER_DEBUG).add(info);
  }
  
  override public function update():Void 
  {
    super.update();
    updateInfo();
    info.visible = false;
    
    
  }
  
  public function update_position():Void {
    if (FlxG.mouse.pressed) {
      var pt:FlxPoint = FlxG.mouse.getWorldPosition();
      spr.x = pt.x - clickPosition.x;
      spr.y = pt.y - clickPosition.y;
      updateInfo();
    }
  }
  
  public function select(pt:FlxPoint):Void {
    clickPosition.x = pt.x - spr.x;
    clickPosition.y = pt.y - spr.y;
  }
  public function unselect():Void {
    clickPosition.x = clickPosition.y = -1;
  }
  
  function updateInfo():Void {
    info.text = spr.x + "," + spr.y;
    info.x = spr.x;
    info.y = spr.y;
  }
  
  public function show():Void { spr.visible = true; }
  public function hide():Void { spr.visible = false; }
  public function setVisible(flag:Bool):Void { spr.visible = flag; }
}