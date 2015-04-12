package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;


import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class BaseState extends FlxState
{
  static public var root:BaseState;
  
	override public function create():Void
	{
    root = this;
    
		FlxG.mouse.useSystemCursor = true;
		
		super.create();
    
    add(new DebugBox());
    add(new Canvas());
    add(new AtlasBrowser());
    
    //FlxG.bgColor = 
    //FlxG.camera.follow(Canvas.canvas);
    
    new FileBridge();
	}
  
  override public function update():Void 
  {
    super.update();
    
  }
  
}