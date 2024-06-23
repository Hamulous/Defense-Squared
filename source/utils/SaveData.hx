package utils;

import flixel.util.FlxSave;
import flixel.FlxG;

class SaveData
{
    public static var exampleBool:Bool = false;

    public static function load()
    {
        if (FlxG.save.data.exampleBool != null)
        {
            exampleBool = FlxG.save.data.exampleBool;
        }
    }

    public static function save()
    {
        FlxG.save.data.exampleBool = exampleBool;

        FlxG.save.flush();
    }
}