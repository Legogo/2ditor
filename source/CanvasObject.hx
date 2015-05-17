package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
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
class CanvasObject extends FlxGroup
{
  
  var lineStyle:Object = { color: FlxColor.CYAN, thickness: 5 };
  var visual_selection:FlxSprite; //overlay on selected
  
  public var x:Float = 0;
  public var y:Float = 0;
  public var spr:FlxSprite; // symbol
  
  var debug_info:FlxText;
  public var staticObject:Bool = false;
  
  public var name:String = "";
  var clickPosition:FlxPoint = new FlxPoint();
  var bounds:Rectangle = new Rectangle();
  
  var canvas:Canvas;
  
  public function new(canvas:Canvas, sprite:FlxSprite) 
  {
    super();
    
    this.canvas = canvas;
    
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
    
    spr.x = x + canvas.position.x;
    spr.y = y + canvas.position.y;
    
    debug_info.x = visual_selection.x = spr.x;
    debug_info.y = visual_selection.y = spr.y;
  }
  
  public function move_start() {
    var pt:FlxPoint = FlxG.mouse.getWorldPosition();
    clickPosition.x = pt.x - x;
    clickPosition.y = pt.y - y;
  }
  
  public function move_step(worldpos:FlxPoint):Void {
    x = worldpos.x - clickPosition.x;
    y = worldpos.y - clickPosition.y;
    updateInfo();
  }
  
  public function move_update() {
    var pt:FlxPoint = FlxG.mouse.getWorldPosition();
    move_step(pt);
  }
  
  public function move_end() {
    clickPosition.x = clickPosition.y = -1;
  }
  
  public function select():Void {
    debug_info.visible = true;
    visual_selection.visible = true;
    updateInfo();
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
    debug_info.text = "#" + name;
    debug_info.text += "\n" + spr.x + ", " + spr.y;
    debug_info.text += ((isSelected()) ? "\nSELECTED" : "");
  }
  
  public function getBounds():Rectangle {
    bounds.x = x;
    bounds.y = y;
    bounds.width = spr.width;
    bounds.height = spr.height;
    return bounds;
  }
  
  public function getPosition():Point {
    return new Point(x, y);
  }
  public function setPosition(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;
    updateInfo();
  }
  
  static public function fromObject(fileObject:Object):CanvasObject {
    
    trace(fileObject);
    var assetId:Int = Std.parseInt(fileObject.assetId);
    var graph:FlxSprite = AtlasBrowser.atlasBrowser.getAtlasSpriteByAssetId(assetId);
    if (graph == null) {
      trace("[WARNING] <CanvasObject> no sprite returned for assetId : " + assetId);
      return null;
    }
    
    var sp:FlxSprite = new FlxSprite(graph.cachedGraphics);
    sp.origin.x = sp.origin.y = 0;
    var obj:CanvasObject = new CanvasObject(Canvas.canvas, sp);
    
    var positionString:String = fileObject.position;
    var pos:Array<String> = positionString.split('x');
    
    obj.setPosition(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]));
    
    //trace("<CanvasObject> created object | assetId : " + assetId + " | position : " + positionString);
    
    return obj;
  }
  
  public function toObject():Object {
    return { assetId:Std.parseInt(name), position:x + "x" + y };
  }
  
  public function show():Void { spr.visible = true; }
  public function hide():Void { spr.visible = false; }
  public function setVisible(flag:Bool):Void { spr.visible = flag; }
}