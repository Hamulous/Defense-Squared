package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxG;

class SpreadProjectile extends FlxSprite {
    private var targets:Array<Bloon>;
    private var damage:Int = 1; // Damage this projectile deals
    private var killInSeconds:Float = 1; // Time in seconds before the projectile is killed
    private var timeAlive:Float = 0; // Tracks how long the projectile has been alive

    public function new(X:Float, Y:Float, velocityX:Float, velocityY:Float, Targets:Array<Bloon>) {
        super(X, Y);
        makeGraphic(8, 8, FlxColor.YELLOW);
        velocity.set(velocityX, velocityY);
        targets = Targets;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        timeAlive += elapsed; // Update the time the projectile has been alive

        // Check if the projectile should be killed due to time
        if (timeAlive >= killInSeconds) {
            kill();
            return;
        }
        
        var closestTarget:Bloon = findClosestTarget();
        if (closestTarget != null) {
            if (calculateDistance(closestTarget) < 10) {
                closestTarget.takeDamage(damage);
                if (!closestTarget.alive) {
                    targets.remove(closestTarget);
                }
                kill();
            }
        } else {
            kill();
        }

        if (x < 0 || x > FlxG.width || y < 0 || y > FlxG.height) {
            kill();
        }
    }

    private function findClosestTarget():Bloon {
        var closest:Bloon = null;
        var closestDistance:Float = Math.POSITIVE_INFINITY;

        for (target in targets) {
            if (target.alive) {
                var distance:Float = calculateDistance(target);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closest = target;
                }
            }
        }

        return closest;
    }

    private function calculateDistance(bloon:Bloon):Float {
        var dx:Float = x - bloon.x;
        var dy:Float = y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}