//I'm gonna go ahead and say, I'm aware of how dogshit this thing is
package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class SpreadTower extends FlxSprite {
    public var fireRate:Float = 1.5; // Time in seconds between shots
    private var timeSinceLastShot:Float = 0;
    private var projectiles:FlxTypedGroup<Dynamic>; // Accept both types of projectiles
    private var angleStep:Float = 360;
    private var projectileCount:Int = 8;

    public function new(X:Float, Y:Float, projectilesGroup:FlxTypedGroup<Dynamic>) {
        super(X, Y);
        makeGraphic(32, 32, FlxColor.PINK);
        projectiles = projectilesGroup;
        angleStep = 360 / projectileCount;
    }
    
    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var closestBloons:Array<Bloon> = findClosestBloons(bloons, 100);
            if (closestBloons.length > 0) {
                shoot(closestBloons);
                timeSinceLastShot = 0;
            }
        }
    }

    private function findClosestBloons(bloons:FlxTypedGroup<Bloon>, radius:Float):Array<Bloon> {
        var closestBloons:Array<Bloon> = [];

        for (bloon in bloons) {
            if (bloon.exists && calculateDistance(new FlxPoint(x, y), bloon) < radius) {
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

    private function shoot(targets:Array<Bloon>):Void {
        for (i in 0...projectileCount) {
            var angle:Float = angleStep * i;
            var radians:Float = angle * Math.PI / 180;
            var velocityX:Float = Math.cos(radians) * 80;
            var velocityY:Float = Math.sin(radians) * 80;

            var projectile:SpreadProjectile = new SpreadProjectile(x, y, velocityX, velocityY, targets);
            projectiles.add(projectile);
        }
    }
}