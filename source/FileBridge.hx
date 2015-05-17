package;

import haxe.Json;
import openfl.utils.Object;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * {
 *   assets:{list[{filename,id}],path}
 *   objects:{list[{position,assetId}]}
 * }
 */
class FileBridge
{
  static public var instance:FileBridge;
  
  var fileData:Object;
  
  var lines:Array<String> = new Array<String>();
  var filePath:String = "level-data.json";
  
  public function new() 
  {
    instance = this;
    loadFile();
  }
  
  public function loadFile():Void {
    try {
      fileData = Json.parse(File.getContent(SystemInfo.PATH_FOLDER + filePath));
    }catch(msg:String){
      trace("<FileBridge> Can't load level file");
    }
    
    AtlasBrowser.atlasBrowser.fromObject(fileData);
    Canvas.canvas.fromObject(fileData);
  }
  
  public function saveFile():Void {
    fileData.objects = Canvas.canvas.toObject();
    fileData.assets = AtlasBrowser.atlasBrowser.toObject();
    
    //trace("<SAVING>\n"+fileData);
    
    File.saveContent(SystemInfo.PATH_FOLDER + filePath, Json.stringify(fileData));
    trace("<FileBridge> [FILE SAVED]");
  }
  
}