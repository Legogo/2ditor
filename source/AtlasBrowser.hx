package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import openfl.Assets;
import flash.geom.Matrix;
import flash.display.BitmapData;
import openfl.events.Event;
import systools.Dialogs;
import flixel.ui.FlxButton;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * ...
 * @author 
 */
class AtlasBrowser extends FlxGroup
{
  static public var atlasBrowser:AtlasBrowser;
  
  var btnImport:FlxButton;
  var btnRemove:FlxButton;
  
  var list:Array<String>;
  var sprites:Array<FlxSprite> = new Array<FlxSprite>();
  
  var selectIdx:Int = 0;
  
  var atlasFilePath:String = "";
  
  var slotSize:Int = 0;
  
  public function new() 
  {
    super();
    atlasBrowser = this;
    BaseState.root.add(this);
    
    atlasFilePath = SystemInfo.PATH_ATLAS;
    
    slotSize = Math.floor(FlxG.width * 0.1);
    
    add(btnImport = new FlxButton(0, FlxG.height - 20, "Import", onImport));
    add(btnRemove = new FlxButton(100, FlxG.height - 20, "Remove", onRemove));
    
    btnImport.scrollFactor.set();
    btnRemove.scrollFactor.set();
    
    update_atlas();
  }
  
  override public function update():Void 
  {
    super.update();
    
    update_ui();
    
    if (FlxG.mouse.justReleased) {
      var pos:FlxPoint = FlxG.mouse.getScreenPosition();
      //trace(pos.x, pos.y);
      
      //top of screen
      if (pos.y < slotSize) {
        var slot:Int = Math.floor(pos.x / slotSize);
        
        if (selectIdx != slot) {
          selectIdx = slot;
          return;
        }else {
          event_insertToCanvas();
        }
        
      }
      
    }
    
  }
  
  function event_insertToCanvas():Void {
    if (selectIdx < 0) return;
    Canvas.canvas.addAsset(sprites[selectIdx]);
  }
  
  public function update_atlas():Void {
    
    update_list();
    
    //clear list
    for (i in 0...sprites.length) {
      if (sprites[i] == null) continue;
      sprites[i].exists = false;
      this.remove(sprites[i]);
      sprites[i] = null;
    }
    
    for (i in 0...list.length) {
      var sp:FlxSprite = update_asset(list[i]);
      sprites[i] = sp;
      sp.origin.x = 0;
      sp.origin.y = 0;
      //sp.makeGraphic(size, size, FlxColor.WHITE);
      scaleImageHorizontally(sprites[i], 0.1);
      sp.x = i * slotSize;
      sp.y = 0;
      
    }
  }
  
  function countAssetInList():Int {
    var count:Int = 0;
    for (i in 0...sprites.length) 
    {
      if (sprites[i] != null) count++;
    }
    return count;
  }
  
  function update_asset(path:String):FlxSprite {
    
    var sp:FlxSprite = new FlxSprite();
    add(sp);
    
    var data:BitmapData = BitmapData.load(path);
    
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		
		sp.makeGraphic(Std.int(data.width), Std.int(data.height), FlxColor.BLACK);
		sp.pixels = data;
    
    return sp;
	}
  
  public function addAssets(assets:Array<String>):Void {
    if (assets == null) return;
    
    trace("<Atlas> adding " + assets.length + " assets");
    for (i in 0...assets.length) 
    {
      addAsset(assets[i]);
    }
    
    update_atlas();
  }
  
  public function onRemove():Void {
    removeAsset(list[selectIdx]);
  }
  
  function onImport():Void {
    var filter:FILEFILTERS = { count: 1, descriptions: ["PNG"], extensions: ["*.png"]};
    var result:Array<String> = Dialogs.openFile("Import image", "message ?", filter);
    addAssets(result);
  }
  
  public function update_ui():Void {
    btnRemove.visible = AtlasBrowser.atlasBrowser.hasSelection();
  }
	
  function update_list():Void {
    var c:String = File.getContent(SystemInfo.PATH_FOLDER + atlasFilePath);
    var all:Array<String> = c.split('\n');
    list = new Array<String>();
    
    //remove empty lines
    for (i in 0...all.length) 
    {
      if (all[i].length > 0) {
        list.push(all[i]);
      }
    }
    
  }
  
  public function removeAsset(path:String):Void {
    if (path.length <= 0) return;
    
    //rewrite all without selection
    var content:String = "";
    for (i in 0...list.length) 
    {
      if (list[i] != path) content += list[i] + "\n";
    }
    File.saveContent(SystemInfo.PATH_FOLDER + atlasFilePath, content);
    
    update_atlas();
  }
  
  
  public function addAsset(path:String):Void {
    if (path.length <= 0) return;
    
    var content:String = File.getContent(SystemInfo.PATH_FOLDER + atlasFilePath);
    if (content.indexOf(path) < 0) {
      content += "\n" + path;
      File.saveContent(SystemInfo.PATH_FOLDER + atlasFilePath, content);
    }else {
      DebugBox.log(path + " is already in atlas");
    }
    
  }
  
  public function hasSelection():Bool { 
    if (countAssetInList() <= 0) {
      selectIdx = -1;
      return false;
    }
    return selectIdx >= 0;
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