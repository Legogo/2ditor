package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.geom.Rectangle;
import openfl.utils.Object;

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
  
  var statePan:Bool = false;
  var stateSelection:Bool = false;
  var stateSnap:Bool = false;
  var stateMoveSelection:Bool = false;
  
  var origin:CanvasObject;
  var underMouseObject:CanvasObject;
  
  public function new() 
  {
    super();
    
    origin = new CanvasOrigin();
    objects.push(origin);
    add(origin.spr);
    
    canvas = this;
    
    Layers.getLayer(Layers.LAYER_CANVAS).add(this);
  }
  
  override public function update():Void 
  {
    super.update();
    
    //stay pressed
    statePan = FlxG.keys.pressed.SPACE;
    
    //toggle
    if (FlxG.keys.justPressed.S) { stateSnap = !stateSnap; }
    
    update_mouseDelta();
    
    underMouseObject = getObjectUnderMouse();
    var pt:FlxPoint = getMouse();
    
    if (FlxG.mouse.justPressed) {
      stateMoveSelection = false;
      stateSelection = false;
      
      if (underMouseObject != null) {
        stateMoveSelection = true;
        
        //if (selectedObjects.length > 1) { unselectedAll(); }
        if (selectedObjects.length <= 1) { 
          unselectedAll();
          selection_addObject(underMouseObject);
        }
        for (i in 0...selectedObjects.length) { selectedObjects[i].move_start(); }
        
      }else {
        stateSelection = true;
        selectionRectangle.x = pt.x;
        selectionRectangle.y = pt.y;
        selectionRectangle.width = 0;
        selectionRectangle.height = 0;
      }
    }
    
    if (FlxG.mouse.pressed) {
      
      if (stateSelection) {
        selection_update();
      }
      
      if (stateMoveSelection) {
        for (i in 0...selectedObjects.length) { selectedObjects[i].move_update(); }
      }
      
    }
    
    if (FlxG.mouse.justReleased) {
      if (isMouseNearClickOrigin()) {
        unselectedAll();
      }
      stateSelection = false;
      stateMoveSelection = false;
      
      FileBridge.instance.saveFile();
    }
  }
  
  function selection_update():Void {
    
    //update du rectangle de selection
    if (stateSelection) {
      selection_updateRectangle();
      selection_updateList();
    }
    
  }
  
  function unselectedAll():Void {
    trace("UNSELECT OBJECTS");
    for (i in 0...selectedObjects.length) 
    {
      selectedObjects[i].unselect();
    }
    
    //reset list
    selectedObjects = new Array<CanvasObject>();
  }
  
  public function addAssetToCanvas(assetId:Int):Void {
    
    trace("<Canvas> adding asset of id " + assetId);
    
    var obj:CanvasObject = CanvasObject.fromObject(
      {assetId:assetId, position:""+(FlxG.width * 0.5) + "x" + (FlxG.height * 0.5) }
    );
    
    if (obj == null) {
      trace("WARNING no object returned CanvasObject::fromObject()");
      return;
    }
    objects.push(obj);
    obj.name = ""+assetId;
    add(obj);
    
    trace("added asset " + obj.name);
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
      if (objects[i].staticObject) continue;
      
      if (selectionRectangle.intersects(objects[i].getBounds())) {
        selection_addObject(objects[i]);
      }
    }
  }
  
  function selection_addObject(obj:CanvasObject):Void {
    if (obj.staticObject) return;
    obj.select(); // reboot mouse pivot
    
    if (selectedObjects.indexOf(obj) < 0) {
      selectedObjects.push(obj);
      trace("added " + obj + " to selection");
    }
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
    return "none";
  }
  
  function getMouse():FlxPoint {
    return FlxG.mouse.getWorldPosition();
  }
  
  function isMouseNearClickOrigin():Bool {
    var dist:Float = FlxMath.getDistance(mouseOrigin, FlxG.mouse.getWorldPosition());
    //trace("distance ? " + dist+" (origin ? "+mouseOrigin+")");
    if (dist < 5) {
      return true;
    }
    return false;
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
  
  public function getActionLabel():String {
    var s:String = "";
    if (statePan) s = "Pan";
    if (stateSelection) {
      s = "[SELECTION "+selectionRectangle.width+"x"+selectionRectangle.height+"]";
      if (selectedObjects.length > 0) s += "\n" + selectedObjects.length + " objects";
      else s += "\nEmpty selection";
    }
    
		return s;
  }
  
  public function fromObject(obj:Object):Void {
    var list:Array<Object> = obj.objects.list;
    
    if (list == null) {
      trace("WARNING list of fileData is null");
      return;
    }
    
    for (i in 0...list.length) {
      addAssetToCanvas(list[i].assetId);
    }
  }
  
  public function toObject():Object {
    var obj:Object = { list:new Array<Object>() };
    for (i in 0...objects.length) {
      if (objects[i].staticObject) continue;
      obj.list.push(objects[i].toObject());
    }
    return obj;
  }
}