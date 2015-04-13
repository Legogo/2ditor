package;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

/**
 * ...
 * @author 
 */
class Canvas extends FlxGroup
{
  static public var canvas:Canvas;
  
  var zoom:Float = 1;
  
  var objects:Array<CanvasObject> = new Array<CanvasObject>();
  
  var grid:CanvasGrid;
  
  var mouseDelta:FlxPoint = new FlxPoint();
  var lastPosition:FlxPoint = new FlxPoint();
  var mouseOrigin:FlxPoint = new FlxPoint();
  
  var selection:CanvasObject;
  
  var state:Int = 0;
  
  var origin:CanvasObject;
  
  public function new() 
  {
    super();
    
    origin = new CanvasOrigin();
    objects.push(origin);
    add(origin.spr);
    
    grid = new CanvasGrid();
    //objects.push(grid);
    //add(grid.spr);
    
    mouseOrigin.x = mouseOrigin.y = FlxG.width * 0.5;
    
    canvas = this;
  }
  
  public function addAsset(ref:FlxSprite):Void {
    var sp:FlxSprite = new FlxSprite(ref.cachedGraphics);
    sp.origin.x = sp.origin.y = 0;
    objects.push(new CanvasObject(sp));
    add(sp);
  }
  
  override public function update():Void 
  {
    super.update();
    
    if (FlxG.keys.justReleased.SPACE) {
      state = (state == 1) ? 0 : 1;
      if (state <= 0) selection = null;
    }
    /*
    if (FlxG.mouse.wheel != 0) {
      zoom += FlxG.mouse.wheel * 0.1;
      zoom = Math.max(0.2, zoom);
      //trace(zoom);
    }
    */
    
    update_mouseDelta();
    
    switch(state) {
      case 0 : update_cameraMove();
      case 1 : update_objectMove();
    }
    
    update_visual();
  }
  
  function update_mouseDelta():Void {
    
    if (FlxG.mouse.pressed) {
      var pos:FlxPoint = FlxG.mouse.getScreenPosition();
      if (lastPosition.x == 0 && lastPosition.y == 0) {
        lastPosition = pos;
        return;
      }
      
      mouseDelta.x = pos.x - lastPosition.x;
      mouseDelta.y = pos.y - lastPosition.y;
      
      //trace(offset);
      lastPosition = pos;
      
    }else if (FlxG.mouse.justReleased) {
      lastPosition.x = lastPosition.y = 0;
      mouseDelta.x = mouseDelta.y = 0;
      selection = null;
    }
    
  }
  
  function update_objectMove():Void {
    
    if (FlxG.mouse.justPressed) {
      selection = null;
      
      var i:Int = objects.length-1;
      while (i >= 0) {
        
        if (objects[i] != null) {
          if (!objects[i].staticObject) {
            if (objects[i].spr.overlapsPoint(FlxG.mouse.getScreenPosition(), true)) {
              selection = objects[i];
              return;
            }
          }
        }
        i--;
        
      }
      
    }
    
    if (selection == null) return;
    
    selection.move(mouseDelta);
  }
  
  function update_cameraMove():Void {
    mouseOrigin.x += mouseDelta.x;
    mouseOrigin.y += mouseDelta.y;
    
    grid.update_position(mouseDelta);
    
  }
  
  function update_visual():Void {
    
    for (i in 0...objects.length) 
    {
      var spr:FlxSprite = objects[i].spr;
      spr.scale.x = spr.scale.y = zoom;
    }
    
    for (i in 0...objects.length) {
      objects[i].update_position(mouseOrigin);
    }
  }
}