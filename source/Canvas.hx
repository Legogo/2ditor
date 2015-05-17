package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.geom.Point;
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
  
  var ui_tools:CanvasTools;
  var ui_grid:CanvasGrid;
  
  var selection:CanvasSelection;
  var selectedObjects:Array<CanvasObject> = new Array<CanvasObject>();
  
  var statePan:Bool = false;
  var stateSelection:Bool = false;
  var stateMoveSelection:Bool = false;
  
  var origin:CanvasObject;
  var underMouseObject:CanvasObject;
  var cursor:CanvasCursor;
  
  public var position:FlxPoint;
  
  public function new() 
  {
    super();
    
    position = new FlxPoint();
    
    origin = new CanvasOrigin(this);
    Layers.getLayer(Layers.LAYER_CANVAS).add(origin);
    
    ui_grid = new CanvasGrid(this);
    Layers.getLayer(Layers.LAYER_CANVAS).add(ui_grid);
    
    canvas = this;
    Layers.getLayer(Layers.LAYER_CANVAS).add(this);
    
    selection = new CanvasSelection();
    Layers.getLayer(Layers.LAYER_UI).add(selection);
    
    cursor = new CanvasCursor();
    Layers.getLayer(Layers.LAYER_UI).add(cursor);
    
    ui_tools = new CanvasTools(this, ui_grid);
  }
  
  override public function update():Void 
  {
    super.update();
    
    update_pan();
    
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
        
        //reset rect
        selection.reset(pt);
      }
    }
    
    if (FlxG.mouse.pressed) {
      
      if (stateSelection) { selection_update(); }
      
      if (stateMoveSelection) {
        
        if (ui_grid.visible) {
          var pt:FlxPoint = getMouse();
          pt.x -= position.x;
          pt.y -= position.y;
          if(ui_grid.visible) pt = ui_grid.snapPosition(pt);
          //for (i in 0...selectedObjects.length) { selectedObjects[i].move_step(pt); }
          for (i in 0...selectedObjects.length) { selectedObjects[i].setPosition(pt.x,pt.y); }
        }else {
          for (i in 0...selectedObjects.length) { selectedObjects[i].move_update(); }
        }
        
      }
      
    }
    
    if (FlxG.mouse.justReleased) {
      if (cursor.left_mouseMoved) {
        unselectedAll();
      }
      stateSelection = false;
      stateMoveSelection = false;
      
      FileBridge.instance.saveFile();
    }
    
    selection.visible = stateSelection;
  }
  
  function selection_update():Void {
    
    //update du rectangle de selection
    if (stateSelection) {
      
      var pt:FlxPoint = getMouse();
      //pt.x -= position.x;pt.y -= position.y;
      selection.updateSelection(pt); // draw rectangle
      selection_updateList();
    }
    
  }
  
  function unselectedAll():Void {
    trace("<Canvas> UNSELECT OBJECTS");
    for (i in 0...selectedObjects.length) 
    {
      selectedObjects[i].unselect();
    }
    
    //reset list
    selectedObjects = new Array<CanvasObject>();
  }
  
  public function addAssetToCanvas(assetId:Int, position:String = ""):Void {
    
    //trace("<Canvas> adding asset of id " + assetId + " pos ? " + position);
    
    if (position.length <= 0) position = (FlxG.width * 0.5) + "x" + (FlxG.height * 0.5);
    
    var obj:Object = { assetId:assetId, position:position };
    var cObject:CanvasObject = CanvasObject.fromObject(obj);
    
    if (cObject == null) {
      trace("WARNING no object returned CanvasObject::fromObject()");
      return;
    }
    
    objects.push(cObject);
    cObject.name = ""+assetId;
    add(cObject);
  }
  
  function selection_updateList():Void {
    var r:Rectangle = selection.getRectangle();
    
    //add all objects in rectangle
    for (i in 0...objects.length) 
    {
      if (objects[i].staticObject) continue;
      
      if (r.intersects(objects[i].getBounds())) {
        selection_addObject(objects[i]);
      }
    }
  }
  
  function selection_addObject(obj:CanvasObject):Void {
    if (obj.staticObject) return;
    obj.select(); // reboot mouse pivot
    
    if (selectedObjects.indexOf(obj) < 0) {
      selectedObjects.push(obj);
      trace("<Canvas> added " + obj + " to selection");
    }
  }
  
  function update_pan():Void {
    
    //stay pressed
    if (FlxG.mouse.justPressedMiddle) {
      statePan = true;
    }else if (FlxG.mouse.justReleasedMiddle) {
      statePan = false;
    }
    
    if (statePan) {
      position.x += cursor.delta.x;
      position.y += cursor.delta.y;
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
    var mouse:FlxPoint = FlxG.mouse.getWorldPosition();
    //mouse.x += position.x;mouse.y += position.y;
    return mouse;
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
      var r:Rectangle = selection.getRectangle();
      s = "[SELECTION "+r.width+"x"+r.height+"]";
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
      addAssetToCanvas(list[i].assetId, list[i].position);
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