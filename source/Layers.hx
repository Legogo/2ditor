package;
import flixel.FlxState;
import flixel.group.FlxGroup;

/**
 * ...
 * @author 
 */
class Layers
{

  static public var root:FlxState;
	
	static private var layers:Array<FlxGroup> = new Array<FlxGroup>();
	
	static public var LAYER_CANVAS:Int = 0;
  static public var LAYER_UI:Int = 1;
	static public var LAYER_DEBUG:Int = 2;
	
	static public function getLayer(idx:Int):FlxGroup {
		while (layers.length <= idx) addLayer();
		return layers[idx];
	}
	
	static public function addLayer():FlxGroup {
		var l:FlxGroup = new FlxGroup();
		layers.push(l);
		root.add(l);
		return l;
	}
	
}