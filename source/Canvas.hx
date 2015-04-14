package;
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
  
  var selectedObject:CanvasObject;
  
	var state_move_object:Int = 0;
	var state_pan_camera:Int = 1;
	var state_selection:Int = 2;
	
  var state:Int = 0;
  
  var snapState:Bool = false;
  
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
    
    Layers.getLayer(Layers.LAYER_CANVAS).add(this);
  }
  
  public function addAsset(ref:FlxSprite):Void {
    var sp:FlxSprite = new FlxSprite(ref.cachedGraphics);
    sp.origin.x = sp.origin.y = 0;
    var obj:CanvasObject = new CanvasObject(sp);
    objects.push(obj);
    add(obj);
  }
  
  override public function update():Void 
  {
    super.update();
    
    state = (FlxG.keys.pressed.SPACE) ? 0 : 1;
    
    selectionUpdate();
    
    if (FlxG.keys.justPressed.S) {
      snapState = !snapState;
    }
    
  }
  
  function selectionUpdate():Void {
    
    if (FlxG.mouse.justPressed) {
      var i:Int = objects.length-1;
      while (i >= 0) {
        if (selectedObject == null) {
          if (!objects[i].staticObject) {
            var pt:FlxPoint = FlxG.mouse.getScreenPosition();
            if (objects[i].spr.overlapsPoint(pt, true)) {
              unselect();
              selectedObject = objects[i];
              selectedObject.select(pt);
            }
          }
        }
        i--;
      }
    }else if (FlxG.mouse.pressed) {
      if (selectedObject != null) {
        selectedObject.update_position();
      }
    }else if (FlxG.mouse.justReleased) {
      unselect();
    }
    
  }
  
  function unselect():Void {
    if (selectedObject != null) {
      selectedObject.unselect();
      selectedObject = null;
    }
  }
  
  function update_mouseDelta():Void {
    
		var pos:FlxPoint = FlxG.mouse.getScreenPosition();
		
		if (FlxG.mouse.justReleased) {
			mouseDelta.x = mouseDelta.y = 0;
			lastPosition.x = lastPosition.y = 0;
			selectedObject = null;
			return;
		}
		
    if (FlxG.mouse.justPressed) {
      lastPosition = pos;
      return;
    }
    
		if (FlxG.mouse.pressed) {
			mouseDelta.x = pos.x - lastPosition.x;
			mouseDelta.y = pos.y - lastPosition.y;
      lastPosition.x = pos.x;
      lastPosition.y = pos.y;
		}
		
  }
  
  function update_cameraMove():Void {
    
    mouseOrigin.x += mouseDelta.x;
    mouseOrigin.y += mouseDelta.y;
    
  }
  
  function update_visual():Void {
    
    for (i in 0...objects.length) 
    {
      var spr:FlxSprite = objects[i].spr;
      spr.scale.x = spr.scale.y = zoom;
    }
    
  }
  
  public function getActionLabel():String {
		switch(state) {
			case 0 : return "Move object";
			case 1 : return "Pan camera";
			case 2 : return "Selection";
		}
		return "";
  }
}