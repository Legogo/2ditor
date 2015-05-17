package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author 
 */
class CanvasTools extends FlxGroup
{

  var icon_grid:UiButton;
  
  var grid:CanvasGrid;
  var canvas:Canvas;
  
  public function new(canvas:Canvas, grid:CanvasGrid) 
  {
    super();
    
    this.canvas = canvas;
    this.grid = grid;
    
    icon_grid = new UiButton(AssetPaths.icon_grid__png, grid.toggle);
    icon_grid.name = "btn_grid";
    add(icon_grid);
    
    Layers.getLayer(Layers.LAYER_UI).add(this);
    
    update_ui();
  }
  
  override public function update():Void 
  {
    super.update();
    
    if (FlxG.keys.justPressed.SPACE) { grid.toggle(); }
    
  }
  
  function update_ui():Void {
    icon_grid.x = 0;
    icon_grid.y = SystemInfo.HEIGHT - icon_grid.height;
  }
  
}