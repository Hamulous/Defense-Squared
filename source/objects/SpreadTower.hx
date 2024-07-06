package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class SpreadTower extends Tower {
    private var projectileSpeed:Float = 100;
    private var projectileCount:Int = 8;
    private var angleStep:Float = 360;
    private var range:Float = 100;

    public function new(X:Float, Y:Float, projectilesGroup:FlxTypedGroup<Dynamic>) {
        super(X, Y, projectilesGroup, false);
        makeGraphic(32, 32, FlxColor.PINK);
        fireRate = 1.5; // Medium-slow fire rate
        angleStep = 360 / projectileCount;
    }

    override public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var target:Bloon = findClosestBloon(bloons);
            if (target != null && calculateDistance(new FlxPoint(x, y), target) <= range) {
                shoot(target);
                timeSinceLastShot = 0;
            }
        }
    }

    override private function shoot(target:Bloon):Void {
        for (i in 0...projectileCount) {
            var angle:Float = angleStep * i;
            var radians:Float = angle * Math.PI / 180;
            var velocityX:Float = Math.cos(radians) * projectileSpeed;
            var velocityY:Float = Math.sin(radians) * projectileSpeed;

            var projectile:SpreadProjectile = new SpreadProjectile(x, y, velocityX, velocityY);
            projectiles.add(projectile);
        }
    }
}
