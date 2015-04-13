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
    
    SystemInfo.HEIGHT = Lib.current.stage.stageHeight;
    SystemInfo.WIDTH = Lib.current.stage.stageWidth;
    
    //FlxG.camera.bgColor = 0x266898;
    bgColor = 0xFF266898;
		FlxG.mouse.useSystemCursor = true;
		
		super.create();
    
    add(new DebugBox());
    add(new Canvas());
    add(new AtlasBrowser());
    
    actionTf = new FlxText(5, FlxG.height - 20, 100, 10);
    add(actionTf);
    
    new FileBridge();
	}
  
  override public function update():Void 
  {
    super.update();
    actionTf.text = Canvas.canvas.getActionLabel();
  }
  
}