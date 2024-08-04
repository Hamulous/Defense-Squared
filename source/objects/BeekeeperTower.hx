package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class BeekeeperTower extends FlxSprite {
    public var fireRate:Float = 25.0; // Time in seconds between shots
    private var timeSinceLastShot:Float = 0;
    public var beeGroup:FlxTypedGroup<Bee>;
    private var definedClosestBloons:Array<Bloon>;

    public function new(x:Float, y:Float, beeGroup:FlxTypedGroup<Bee>) {
        super(x, y);
        makeGraphic(32, 32, 0xFFB22222);
        this.beeGroup = beeGroup;
    }

    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var closestBloons:Array<Bloon> = findClosestBloons(bloons);
            if (closestBloons.length > 0) {
                spawnBee(closestBloons);
                timeSinceLastShot = 0;
            }
        }
    }

    private function findClosestBloons(bloons:FlxTypedGroup<Bloon>):Array<Bloon> {
        var closestBloons:Array<Bloon> = [];

        for (bloon in bloons) {
            if (bloon.exists) {
                closestBloons.push(bloon);
            }
        }

        return closestBloons;
    }

    private function calculateDistance(point:FlxPoint, bloon:Bloon):Float {
        var dx:Float = point.x - bloon.x;
        var dy:Float = point.y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function spawnBee(targets:Array<Bloon>):Void {
        var bee = new Bee(x, y, targets);
        beeGroup.add(bee);
    }
}