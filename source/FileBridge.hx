package;

import haxe.Json;
import openfl.utils.Object;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * ...
 * @author 
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
      AtlasBrowser.atlasBrowser.fromObject(fileData);
    }catch(msg:String){
      trace("Can't load level file");
    }
  }
  
  public function saveFile():Void {
    fileData.objects = [];
    fileData.assets = AtlasBrowser.atlasBrowser.toObject();
    
    File.saveContent(SystemInfo.PATH_FOLDER + filePath, Json.stringify(fileData));
    trace("[FILE SAVED]");
  }
  
}