package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class Tower extends FlxSprite {
    public var fireRate:Float = 1.0; // Time in seconds between shots
    private var timeSinceLastShot:Float = 0;
    private var projectiles:FlxTypedGroup<Dynamic>; // Accept both types of projectiles
    private var isBoomerang:Bool;

    public function new(X:Float, Y:Float, projectilesGroup:FlxTypedGroup<Dynamic>, boomerang:Bool) {
        super(X, Y);
        if (boomerang) {
            makeGraphic(32, 32, FlxColor.GRAY);
        } else {
            makeGraphic(32, 32, FlxColor.BLUE);
        }
        projectiles = projectilesGroup;
        isBoomerang = boomerang;
    }
    
    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var target:Bloon = findClosestBloon(bloons);
            if (target != null && calculateDistance(new FlxPoint(x, y), target) < 100) {
                shoot(target);
                timeSinceLastShot = 0;
            }
        }
    }

    private function findClosestBloon(bloons:FlxTypedGroup<Bloon>):Bloon {
        var closest:Bloon = null;
        var closestDist:Float = Math.POSITIVE_INFINITY;
        
        for (bloon in bloons) {
            var dist:Float = calculateDistance(new FlxPoint(x, y), bloon);
            if (dist < closestDist) {
                closestDist = dist;
                closest = bloon;
            }
        }
        
        return closest;
    }

    private function calculateDistance(point:FlxPoint, bloon:Bloon):Float {
        var dx:Float = point.x - bloon.x;
        var dy:Float = point.y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function shoot(target:Bloon):Void {
        var projectile:Dynamic;
        if (isBoomerang) {
            projectile = new BoomerangProjectile(x, y, target);
        } else {
            projectile = new Projectile(x, y, target);
        }
        projectiles.add(projectile);
    }
}