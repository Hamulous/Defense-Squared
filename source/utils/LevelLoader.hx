package utils;

import haxe.format.JsonParser;
import openfl.Assets;
import flixel.math.FlxPoint;

class LevelLoader {
    public static function loadLevel(levelName:String, callback:Dynamic->Void):Void {
        var path = "assets/data/" + levelName + ".json";
        var jsonData:String = Assets.getText(path);
        var levelData:Dynamic = JsonParser.parse(jsonData);

        // Explicitly cast Dynamic to Array<Dynamic> for iteration
        var waypoints:Array<Dynamic> = levelData.waypoints;
        var waves:Array<Dynamic> = levelData.waves;
        var waterTiles:Array<Dynamic> = levelData.waterTiles;

        // Convert waypoints
        var waypointPoints:Array<FlxPoint> = [];
        for (wp in waypoints) {
            waypointPoints.push(new FlxPoint(wp.x, wp.y));
        }

        // Convert waves
        var waveObjects:Array<Wave> = [];
        for (waveData in waves) {
            waveObjects.push(new Wave(waveData.count, waveData.interval, 1, waypointPoints));
        }

        // Call the callback with the loaded data
        callback({waypoints: waypointPoints, waves: waveObjects, waterTiles: waterTiles});
    }
}