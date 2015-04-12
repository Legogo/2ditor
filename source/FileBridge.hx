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
  public var levelData:Object;
  public var atlasData:Object;
  
  var lines:Array<String> = new Array<String>();
  
  var filePath:String = "level-data.json";
  
  public function new() 
  {
    instance = this;
    loadFile();
  }
  
  public function loadFile():Void {
    fileData = Json.parse(File.getContent(SystemInfo.PATH_FOLDER + filePath));
    levelData = fileData[0];
    atlasData = fileData[1];
    
    AtlasBrowser.atlasBrowser.fromObject(atlasData);
  }
  
  public function saveFile():Void {
    fileData[0] = levelData;
    
    atlasData = AtlasBrowser.atlasBrowser.toObject();
    fileData[1] = atlasData;
    
    File.saveContent(SystemInfo.PATH_FOLDER + filePath, Json.stringify(fileData));
  }
  
}