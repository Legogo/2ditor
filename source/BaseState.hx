package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import openfl.Lib;


import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class BaseState extends FlxState
{
  static public var root:BaseState;
  
  var actionTf:FlxText;
  
	override public function create():Void
	{
    root = this;
    Layers.root = this;
    
    SystemInfo.HEIGHT = Lib.current.stage.stageHeight;
    SystemInfo.WIDTH = Lib.current.stage.stageWidth;
    
    //FlxG.camera.bgColor = 0x266898;
    bgColor = 0xFF266898;
		FlxG.mouse.useSystemCursor = true;
		
		super.create();
    
    new Canvas();
    new AtlasBrowser();
    
    actionTf = new FlxText(5, FlxG.height - 40, 300, 10);
    Layers.getLayer(Layers.LAYER_DEBUG).add(actionTf);
    
    Layers.getLayer(Layers.LAYER_DEBUG).add(new DebugBox());
    
    new FileBridge();
	}
  
  override public function update():Void 
  {
    super.update();
    
    actionTf.text = "";
    
    var obj:CanvasObject = Canvas.canvas.getHoverObject();
    if (obj != null) actionTf.text = "Hovering " + obj.name;
    
    actionTf.text += "\n"+Canvas.canvas.getActionLabel();
  }
  
}