package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class BoomerangProjectile extends FlxSprite {
    private var target:Bloon;
    private var pointOrigin:FlxPoint;
    private var controlPoint:FlxPoint;
    private var speed:Float = 650;
    private var t:Float = 0;
    private var returning:Bool = false;
    public var returned:Bool = false;
    private var damage:Int = 3; // Damage this projectile deals

    public function new(X:Float, Y:Float, Target:Bloon) {
        super(X, Y);
        makeGraphic(8, 8, FlxColor.ORANGE);
        target = Target;
        pointOrigin = new FlxPoint(X, Y);
        controlPoint = new FlxPoint((X + Target.x) / 2, Y - 50); // Adjust the control point for the desired curve
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (t >= 1 && !returning) {
            returning = true;
            t = 0;
        }

        t += speed * elapsed / 1000;

        if (!returning) {
            var newPos:FlxPoint = getBezierPoint(t, pointOrigin, controlPoint, new FlxPoint(target.x, target.y));
            x = newPos.x;
            y = newPos.y;
            if (calculateDistance(newPos, new FlxPoint(target.x, target.y)) < 8) {
                target.takeDamage(damage);
            }
        } else {
            var newPos:FlxPoint = getBezierPoint(t, new FlxPoint(target.x, target.y), controlPoint, pointOrigin);
            x = newPos.x;
            y = newPos.y;
            if (calculateDistance(newPos, pointOrigin) < 8) {
                returned = true;
                kill();
            }
        }
    }

    private function calculateDistance(point1:FlxPoint, point2:FlxPoint):Float {
        var dx:Float = point1.x - point2.x;
        var dy:Float = point1.y - point2.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function getBezierPoint(t:Float, p0:FlxPoint, p1:FlxPoint, p2:FlxPoint):FlxPoint {
        var u:Float = 1 - t;
        var tt:Float = t * t;
        var uu:Float = u * u;
        
        var p:FlxPoint = new FlxPoint();
        p.x = uu * p0.x;
        p.x += 2 * u * t * p1.x;
        p.x += tt * p2.x;

        p.y = uu * p0.y;
        p.y += 2 * u * t * p1.y;
        p.y += tt * p2.y;

        return p;
    }
}