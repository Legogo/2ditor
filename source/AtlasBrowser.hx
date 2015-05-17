package;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.android.FlxAndroidKeyList;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import openfl.Assets;
import flash.geom.Matrix;
import flash.display.BitmapData;
import openfl.events.Event;
import openfl.utils.Object;
import sys.io.FileSeek;
import systools.Dialogs;
import flixel.ui.FlxButton;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.FileSystem;

/**
 * ...
 * @author 
 */
class AtlasBrowser extends FlxGroup
{
  static public var atlasBrowser:AtlasBrowser;
  
  var btnImport:FlxButton;
  var btnRemove:FlxButton;
  
  var sprites:FlxGroup = new FlxGroup(); // all symbols
  
  var selectIdx:Int = 0;
  var slotSize:Int = 0;
  
  var slotSelectionVisual:AtlasBrowserSelector;
  
	var resourcePath:String = "";
  var assets:Array<Object>; //{id,filename}
  
  public function new() 
  {
    super();
    atlasBrowser = this;
    
    slotSize = Math.floor(FlxG.width * 0.1);
    
    add(btnImport = new FlxButton(0, slotSize+10, "Import", onImport));
    add(btnRemove = new FlxButton(75, slotSize+10, "Remove", onRemove));
    
    btnImport.scrollFactor.set();
    btnRemove.scrollFactor.set();
    
    add(sprites);
    
    slotSelectionVisual = new AtlasBrowserSelector();
    add(slotSelectionVisual.spr);
    
    Layers.getLayer(Layers.LAYER_UI).add(this);
  }
  
  public function generateAtlas():Void {
    update_atlas();
  }
  
  override public function update():Void 
  {
    super.update();
    
    update_ui();
    
    var slotIdx:Int = getMouseOverIndex();
    
    if (slotIdx > -1) {
      if (FlxG.mouse.justReleased) {
        if (selectIdx != slotIdx) {
          setSelectionSlot(slotIdx);
          slotSelectionVisual.update_slotIndex(selectIdx);
        }else {
          event_insertToCanvas();
        }
      }
    }
    
  }
  
  function getMouseOverIndex():Int {
    var pos:FlxPoint = FlxG.mouse.getScreenPosition();
      //trace(pos.x, pos.y);
      
    //top of screen
    if (pos.y < slotSize) {
      var slot:Int = Math.floor(pos.x / slotSize);
      if (slot < assets.length) {
        return slot;
      }
    }
    
    return -1;
  }
  
  public function getAtlasSpriteByAssetId(id:Int):FlxSprite {
    for (i in 0...assets.length) {
      if (Std.parseInt(assets[i].id) == id) return AtlasBrowser.getSpriteFromFilePath(resourcePath + assets[i].filename);
    }
    trace("WARNING can't find atlas sprite by asset id " + id);
    return null;
  }
  
  public function getAtlasSpriteByIndex(idx:Int):FlxSprite {
    if (sprites == null) {
      trace("WARNING sprites object is null");
      return null;
    }
    return cast(sprites.members[idx], FlxSprite);
  }
  
  function event_insertToCanvas():Void {
    if (selectIdx < 0) return;
    Canvas.canvas.addAssetToCanvas(assets[selectIdx].id); // default position is center of screen
  }
  
  public function update_atlas():Void {
    
    //empty/clear old sprites list
    for (i in 0...sprites.length) {
      if (sprites.members[i] == null) continue;
      sprites.members[i].exists = false;
      this.remove(sprites.members[i]);
      sprites.members[i] = null;
    }
    
    if (assets == null) return;
    
    for (i in 0...assets.length) {
      //var ao:AtlasObject = new AtlasObject(assets[i].id, assets[i].filename, resourcePath);
      var sp:FlxSprite = AtlasBrowser.getSpriteFromFilePath(resourcePath+assets[i].filename);
			if (sp != null) {
				sp.origin.x = 0;
				sp.origin.y = 0;
				//sp.makeGraphic(size, size, FlxColor.WHITE);
				scaleImageHorizontally(sp, 0.1);
				sp.x = i * slotSize;
				sp.y = 0;
        sprites.add(sp);
			}
    }
    
    if (selectIdx >= assets.length) setSelectionSlot(assets.length - 1);
  }
  
  function countAssetInList():Int {
    var count:Int = 0;
    for (i in 0...sprites.length) 
    {
      if (sprites.members[i] != null) count++;
    }
    return count;
  }
  
  static public function getSpriteFromFilePath(fullPath:String):FlxSprite {
    
    //trace("<AtlasBrowser> loading " + fullPath);
    var data:BitmapData = BitmapData.load(fullPath);
    
		if (data.width <= 0) {
			trace("WARNING could not find file at path : " + fullPath + ". Width = 0");
			return null;
		}
		
    var sp:FlxSprite = new FlxSprite();
    
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		
		sp.makeGraphic(Std.int(data.width), Std.int(data.height), FlxColor.BLACK);
		sp.pixels = data;
    
    return sp;
	}
  
  public function addAssetsFromBrowser(assets:Array<String>):Void {
    if (assets == null) return;
    
    for (i in 0...assets.length) 
    {
      addAssetFromBrowser(assets[i]);
    }
    trace("<Atlas> added " + assets.length + " assets");
    
    FileBridge.instance.saveFile();
    update_atlas();
  }
  
  
  function addAssetFromBrowser(fullPath:String):Void {
    if (fullPath.length <= 0) return;
    
    var separator:String = (fullPath.indexOf('\\') > -1) ? '\\' : '/';
    var lastIndex:Int = fullPath.lastIndexOf(separator)+1;
    var path:String = fullPath.substr(0, lastIndex);
    var fileName:String = fullPath.substr(lastIndex, fullPath.length - lastIndex);
    
    //trace(fullPath, path, fileName);
    
    if (resourcePath.length <= 0) resourcePath = path;
    else if (path != resourcePath) {
      trace("WARNING path is different than resource path ?");
    }
    
    var exist:Bool = false;
    for (i in 0...assets.length) {
      if (assets[i].filename == fileName) {
        exist = true;
      }
    }
    
    if (!exist) {
      var obj:Object = { id:getUniqId(), filename:fileName };
      assets.push(obj);
      trace("Adding asset : "+obj);
    }
  }
  
  function getUniqId():Int {
    return Math.floor(Math.random() * 999999999);
  }
  
  public function onRemove():Void {
    removeAsset(selectIdx);
  }
  
  function onImport():Void {
    var filter:FILEFILTERS = { count: 1, descriptions: ["PNG"], extensions: ["*.png"]};
    var result:Array<String> = Dialogs.openFile("Import image", "message ?", filter);
    addAssetsFromBrowser(result);
  }
  
  public function update_ui():Void {
    btnRemove.visible = AtlasBrowser.atlasBrowser.hasSelection();
  }
	
  public function removeAsset(idx:Int):Void {
    if (assets.length <= 0) return;
    
    //rewrite all without selection
    var newList:Array<Object> = new Array<Object>();
    for (i in 0...assets.length) 
    {
      if (i != idx) newList.push(assets[i]);
    }
    assets = newList;
    
    FileBridge.instance.saveFile();
    update_atlas();
  }
  
  function setSelectionSlot(newSlot:Int):Void {
    selectIdx = newSlot;
    slotSelectionVisual.setVisible(selectIdx >= 0);
    if (selectIdx >= 0) {
      slotSelectionVisual.update_slotIndex(selectIdx);
    }
  }
  
  public function hasSelection():Bool {
    if (countAssetInList() <= 0) {
      setSelectionSlot( -1);
      return false;
    }
    return selectIdx >= 0;
  }
  
	/* SAVE / LOAD */
	
  public function fromObject(obj:Object):Void {
		var data:Object = obj.assets;
    var obj:Object = null;
    
		//assets
    if (data.list != null) {
      assets = data.list; // [{id,path}]
      obj = assets[0];
      trace("<Atlas>loaded assets : " + assets.length);
    }
    
    //find path
    resourcePath = "";
    if (data.path != null) {
      var list:Array<String> = data.path; // strings
      
      var i:UInt = 0;
      var validPath:String = "";
      for (i in 0...list.length) {
        //File.list[i]+assets["filename"]
        
        if (FileSystem.exists(list[i] + obj.filename)) {
          resourcePath = list[i];
        }
      }
      
      //resourcePath = data.path[0];
    }
    
    if (resourcePath.length <= 0) { throw "[ERROR] No resource path"; }
    
    update_atlas();
  }
  
  public function toObject():Object {
    var o:Object = { };
		o.path = resourcePath;
    o.list = assets;
		return o;
  }
  
  static public function scaleImageHorizontally(img:FlxSprite, ratio:Float):FlxSprite {
    var res:Float = 0;
    res = FlxG.width * ratio; // target pixel size
    res = (res / img.width); // target ratio
    
    img.scale.x = img.scale.y = res;
    return img;
  }
  static public function scaleImageVertically(img:FlxSprite, ratio:Float):FlxSprite {
    var res:Float = 0;
    res = FlxG.height * ratio; // target pixel size
    res = (res / img.height); // target ratio
    
    img.scale.x = img.scale.y = res;
    return img;
  }
  
}