package utils;

import flixel.math.FlxPoint;
import objects.Bloon;

class Wave {
    public var bloonCount:Int;
    public var spawnInterval:Float;
    public var bloonHealth:Int;
    private var waypoints:Array<FlxPoint>;

    public function new(bloonCount:Int, spawnInterval:Float, bloonHealth:Int, waypoints:Array<FlxPoint>) {
        this.bloonCount = bloonCount;
        this.spawnInterval = spawnInterval;
        this.bloonHealth = bloonHealth;
        this.waypoints = waypoints;
    }

    public function spawnBloon():Bloon {
        var bloon:Bloon = new Bloon(waypoints, bloonHealth);
        return bloon;
    }
}