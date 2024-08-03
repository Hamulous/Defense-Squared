package utils;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.FlxG;
import flixel.util.FlxSave;

class SettingsManager {
    public static var volumeLevel:Int = 10;
    public static var currentResolutionIndex:Int = 0;
    public static var resolutions:Array<Dynamic> = [
        {width: 640, height: 480},
        {width: 800, height: 600},
        {width: 1024, height: 768},
        {width: 1280, height: 720},
        {width: 1920, height: 1080}
    ];

    private static var save:FlxSave = new FlxSave();

    public static function loadSettings():Void {
        if (save.bind("MyGameSettings")) {
            if (save.data.volume != null) {
                volumeLevel = save.data.volume;
                FlxG.sound.volume = volumeLevel / 10;
            }
            if (save.data.resolutionIndex != null) {
                currentResolutionIndex = save.data.resolutionIndex;
                setResolution(currentResolutionIndex);
            }
        }
    }

    public static function saveSettings():Void {
        save.data.volume = volumeLevel;
        save.data.resolutionIndex = currentResolutionIndex;
        save.flush();
    }

    public static function setResolution(index:Int):Void {
        var resolution = resolutions[index];
        FlxG.scaleMode = new RatioScaleMode(false);
        FlxG.resizeGame(resolution.width, resolution.height);
        FlxG.resizeWindow(resolution.width, resolution.height);
    }
}
