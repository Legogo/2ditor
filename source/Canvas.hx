package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.geom.Rectangle;

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
  var mouseMoved:Bool = false;
  
  var selectionRectangle:Rectangle = new Rectangle();
  var selectedObjects:Array<CanvasObject> = new Array<CanvasObject>();
  
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
    
    canvas = this;
    
    Layers.getLayer(Layers.LAYER_CANVAS).add(this);
  }
  
  public function addAsset(ref:FlxSprite):Void {
    var sp:FlxSprite = new FlxSprite(ref.cachedGraphics);
    sp.origin.x = sp.origin.y = 0;
    var obj:CanvasObject = new CanvasObject(sp);
    objects.push(obj);
    obj.name = "obj-" + objects.length;
    add(obj);
  }
  
  override public function update():Void 
  {
    super.update();
    
    if (FlxG.keys.pressed.SPACE) {
      state = state_pan_camera;
    }
    
    update_mouseDelta();
    selection_update();
    
    if (FlxG.keys.justPressed.S) {
      snapState = !snapState;
    }
    
  }
  
  function getObjectUnderMouse():CanvasObject {
    var obj:CanvasObject = null;
    var pt:FlxPoint = getMouse();
    var i:Int = objects.length - 1;
    while (i >= 0) {
      if (!objects[i].staticObject) {
        if (objects[i].spr.overlapsPoint(pt, true)) {
          return objects[i];
        }
      }
      i--;
    }
    return null;
  }
  
  function getObjectsUnderMouse():Array<CanvasObject> {
    var list:Array<CanvasObject> = new Array<CanvasObject>();
    var pt:FlxPoint = getMouse();
    var i:Int = objects.length-1;
    while (i >= 0) {
      if (!objects[i].staticObject) {
        if (objects[i].spr.overlapsPoint(pt)) {
          list.push(objects[i]);
        }
      }
      i--;
    }
    return list;
  }
  
  function selection_update():Void {
    if (state == state_pan_camera) return;
    
    var underMouse:CanvasObject = getObjectUnderMouse();
    
    if (FlxG.mouse.justPressed) {
      
      //cliqué dans le vide
      if (underMouse == null) {
        state = state_selection;
        trace("SELECTION");
      }else {
        state = state_move_object;
        selection_addObject(underMouse);
        trace("MOVING OBJECT");
      }
      
      //setup origin of selection rectangle
      if (state == state_selection) {
        var mousePos:FlxPoint = getMouse();
        selectionRectangle.x = mousePos.x;
        selectionRectangle.y = mousePos.y;
      }
      
    }else if (FlxG.mouse.pressed) {
      
      //update du rectangle de selection
      if (isState(state_selection)) {
        selection_updateRectangle();
        selection_updateList();
      }
      
    }else if (FlxG.mouse.justReleased) {
      //trace("RELEASE");
      if (!mouseMoved && underMouse == null) {
        unselect();
      }
      
    }
    
  }
  
  function selection_updateRectangle():Void {
    var pos:FlxPoint = getMouse();
    selectionRectangle.width = pos.x - selectionRectangle.x;
    selectionRectangle.height = pos.y - selectionRectangle.y;
  }
  
  function selection_updateList():Void {
    //add all objects in rectangle
    for (i in 0...objects.length) 
    {
      if (selectionRectangle.containsRect(objects[i].getBounds())) {
        selection_addObject(objects[i]);
      }
    }
  }
  
  function selection_addObject(obj:CanvasObject):Void {
    obj.select(); // reboot mouse pivot
    
    if (selectedObjects.indexOf(obj) < 0) {
      selectedObjects.push(obj);
      trace("added " + obj + " to selection");
    }
  }
  
  function unselect():Void {
    trace("UNSELECT OBJECTS");
    for (i in 0...selectedObjects.length) 
    {
      selectedObjects[i].unselect();
    }
    
    //reset list
    selectedObjects = new Array<CanvasObject>();
  }
  
  function update_mouseDelta():Void {
    
		var pos:FlxPoint = FlxG.mouse.getWorldPosition();
		
		if (FlxG.mouse.justReleased) {
			mouseDelta.x = mouseDelta.y = 0;
			lastPosition.x = lastPosition.y = 0;
			return;
		}
		
    if (FlxG.mouse.justPressed) {
      lastPosition.x = pos.x;
      lastPosition.y = pos.y;
      
      mouseOrigin.x = pos.x;
      mouseOrigin.y = pos.y;
      mouseMoved = false;
      //trace("origin = " + mouseOrigin);
    }
    
		if (FlxG.mouse.pressed) {
			mouseDelta.x = pos.x - lastPosition.x;
			mouseDelta.y = pos.y - lastPosition.y;
      lastPosition.x = pos.x;
      lastPosition.y = pos.y;
      
      if (!isMouseNearClickOrigin()) {
        if (!mouseMoved) {
          mouseMoved = true;
          trace("mouse moved");
        }
      }
		}
		
  }
  
  function update_cameraMove():Void {
    
    for (j in 0...objects.length) 
    {
      if (!objects[j].staticObject) {
        objects[j].update_camera(mouseDelta);
      }
    }
  }
  
  function update_visual():Void {
    
    for (i in 0...objects.length) 
    {
      var spr:FlxSprite = objects[i].spr;
      spr.scale.x = spr.scale.y = zoom;
    }
    
  }
  
  public function getHoverObject():CanvasObject {
    return getObjectUnderMouse();
  }
  public function getHoverObjectName():String {
    var obj:CanvasObject = getObjectUnderMouse();
    if (obj != null) return obj.name;
    return "nothing";
  }
  
  function getMouse():FlxPoint {
    return FlxG.mouse.getWorldPosition();
  }
  
  function isMouseNearClickOrigin():Bool {
    var dist:Float = FlxMath.getDistance(mouseOrigin, FlxG.mouse.getWorldPosition());
    //trace("distance ? " + dist+" (origin ? "+mouseOrigin+")");
    if (dist < 1) {
      return true;
    }
    return false;
  }
  
  public function isState(compareState:Int):Bool {
    return state == compareState;
  }
  
  public function getActionLabel():String {
		switch(state) {
			case 0 : return "Move object";
			case 1 : return "Pan camera";
    case 2 :
      if (selectedObjects.length > 0) return "Selected " + selectedObjects.length + " objects";
      return "Empty selection";
		}
		return "";
  }
}