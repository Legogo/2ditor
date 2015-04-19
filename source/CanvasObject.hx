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
    
  }
  
  public function update_camera(delta:FlxPoint):Void {
    spr.x += delta.x;
    spr.y += delta.y;
  }
  
  public function move_start() {
    var pt:FlxPoint = FlxG.mouse.getWorldPosition();
    clickPosition.x = pt.x - spr.x;
    clickPosition.y = pt.y - spr.y;
  }
  
  public function move_update() {
    var pt:FlxPoint = FlxG.mouse.getWorldPosition();
      spr.x = pt.x - clickPosition.x;
      spr.y = pt.y - clickPosition.y;
      updateInfo();
  }
  
  public function move_end() {
    clickPosition.x = clickPosition.y = -1;
  }
  
  public function select():Void {
    debug_info.visible = true;
    visual_selection.visible = true;
    
    //trace(name + " selected (at "+clickPosition+")");
  }
  
  public function unselect():Void {
    
    debug_info.visible = false;
    visual_selection.visible = false;
    
    //trace(name + " unselected");
  }
  
  public function isSelected():Bool {
    return visual_selection.visible;
  }
  
  function updateInfo():Void {
    debug_info.text = name+" "+spr.x + "," + spr.y+((isSelected()) ? "SELECTED" : "");
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
  
  public function setPosition(x:Float, y:Float):Void {
    spr.x = x;
    spr.y = y;
  }
  
  static public function fromObject(fileObject:Object):CanvasObject {
    
    var assetId:Int = Std.parseInt(fileObject.assetId);
    var graph:FlxSprite = AtlasBrowser.atlasBrowser.getAtlasSpriteByAssetId(assetId);
    if (graph == null) {
      trace("WARNING no sprite returned for assetId : " + assetId);
      return null;
    }
    
    var sp:FlxSprite = new FlxSprite(graph.cachedGraphics);
    sp.origin.x = sp.origin.y = 0;
    var obj:CanvasObject = new CanvasObject(sp);
    
    var positionString:String = fileObject.position;
    var pos:Array<String> = positionString.split('x');
    
    obj.setPosition(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]));
    
    return obj;
  }
  
  public function toObject():Object {
    return { assetId:Std.parseInt(name), position:spr.x + "x" + spr.y };
  }
  
  public function show():Void { spr.visible = true; }
  public function hide():Void { spr.visible = false; }
  public function setVisible(flag:Bool):Void { spr.visible = flag; }
}