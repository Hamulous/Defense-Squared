package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import openfl.Lib;
import utils.SettingsManager;
import Main;

class Init extends FlxState
{
	public override function new()
	{
		super();
	}

	public override function create()
	{
		super.create();

		/*#if cpp
		CppAPI.darkMode();
		#end*/

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end

		/*FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;*/

		FlxG.autoPause = true;

		//Main.canToggleFullScreen = true;

		FlxG.mouse.visible = false;

		SettingsManager.loadSettings();

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}
}