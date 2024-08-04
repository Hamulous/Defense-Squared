package objects;

import flixel.FlxSprite;
import flixel.FlxG;

class Bee extends FlxSprite {
    private var targets:Array<Bloon>;
    private var damage:Int = 1; // Damage this projectile deals
    public var speed:Float = 200;
    private var killInSeconds:Float = 15; // Time in seconds before the projectile is killed
    private var timeAlive:Float = 0; // Tracks how long the projectile has been alive

    public function new(x:Float, y:Float, Targets:Array<Bloon>) {
        super(x, y);
        makeGraphic(10, 10, 0xFFFFD700); // Bee appearance
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
            }
        }

        var targetX:Float = FlxG.mouse.x;
        var targetY:Float = FlxG.mouse.y;

        var angle:Float = Math.atan2(targetY - y, targetX - x);
        velocity.x = Math.cos(angle) * speed;
        velocity.y = Math.sin(angle) * speed;
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