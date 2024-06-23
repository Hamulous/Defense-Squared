package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.FPS;
import openfl.Lib;
import flixel.FlxState;
import openfl.display.StageScaleMode;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 980; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var initialState:Class<FlxState> = states.MainMenuState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 64; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		addChild(new FlxGame(gameWidth, gameHeight, Init, #if (flixel < "5.0.0") zoom,#end framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		/*if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}*/
		#end
	}
}
