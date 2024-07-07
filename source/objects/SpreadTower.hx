package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

class SpreadTower extends FlxSprite {
    public var fireRate:Float = 1.5; // Medium-slow fire rate
    private var timeSinceLastShot:Float = 0;
    private var projectiles:FlxTypedGroup<Projectile>;
    private var range:Float = 50; // Short range

    public function new(X:Float, Y:Float, projectilesGroup:FlxTypedGroup<Projectile>) {
        super(X, Y);
        makeGraphic(32, 32, FlxColor.PINK);
        projectiles = projectilesGroup;
    }
    
    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var targetInRange:Bool = false;
            
            for (bloon in bloons) {
                if (bloon.exists && calculateDistance(new FlxPoint(x, y), bloon) <= range) {
                    targetInRange = true;
                    break;
                }
            }
            
            if (targetInRange) {
                shoot();
                timeSinceLastShot = 0;
            }
        }
    }

    private function calculateDistance(point:FlxPoint, bloon:Bloon):Float {
        var dx:Float = point.x - bloon.x;
        var dy:Float = point.y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function shoot():Void {
        var angles:Array<Float> = [0, 45, 90, 135, 180, 225, 270, 315];
        
        for (angle in angles) {
            var rad:Float = angle * Math.PI / 180;
            var projectile:Projectile = new Projectile(x + width / 2, y + height / 2, null, true);
            projectile.velocity.x = Math.cos(rad) * 200; // Set the speed of the projectile
            projectile.velocity.y = Math.sin(rad) * 200;
            projectiles.add(projectile);
        }
    }
}