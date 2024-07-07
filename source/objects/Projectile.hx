package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class Projectile extends FlxSprite {
    private var target:Bloon;
    private var tackPro:Bool = false;
    private var speed:Float = 200; // Speed of the projectile
    private var damage:Int = 1; // Damage this projectile deals

    public function new(X:Float, Y:Float, Target:Bloon, ?isTack:Bool = false) {
        super(X, Y);
        makeGraphic(8, 8, FlxColor.YELLOW);
        target = Target;
        tackPro = isTack;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (target != null && target.alive) {
            var direction:FlxPoint = new FlxPoint(target.x - x, target.y - y);
            direction.normalize();
            velocity.set(direction.x * speed, direction.y * speed);

            if (calculateDistance(target) < 8) {
                target.takeDamage(damage);
                kill();
            }
        } else if (!tackPro) {
            kill();
        }
    }

    private function calculateDistance(bloon:Bloon):Float {
        var dx:Float = x - bloon.x;
        var dy:Float = y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}