package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Bloon extends FlxSprite {
    private var waypoints:Array<FlxPoint>;
    private var currentWaypointIndex:Int;
    private var speed:Float = 50;
    public var bloonHealth:Int = 3;

    public function new(Waypoints:Array<FlxPoint>, StartIndex:Int) {
        var startPoint = Waypoints[StartIndex];
        super(startPoint.x, startPoint.y);
        makeGraphic(16, 16, FlxColor.RED);
        
        waypoints = Waypoints;
        currentWaypointIndex = StartIndex + 1; // Move towards the next waypoint
        setVelocityTowardsWaypoint();
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        // Check if the bloon has reached the current waypoint
        if (calculateDistance(new FlxPoint(x, y), waypoints[currentWaypointIndex]) < speed * elapsed) {
            currentWaypointIndex++;
            if (currentWaypointIndex < waypoints.length) {
                setVelocityTowardsWaypoint();
            } else {
                // Bloon has reached the end of the path
                kill();
            }
        }
    }
    
    private function setVelocityTowardsWaypoint():Void {
        var target:FlxPoint = waypoints[currentWaypointIndex];
        var direction:FlxPoint = new FlxPoint(target.x - x, target.y - y);
        direction.normalize();
        velocity.set(direction.x * speed, direction.y * speed);
    }

    public function takeDamage(damage:Int):Void {
        bloonHealth -= damage;
        if (bloonHealth <= 0) {
            kill();
        }
    }

    private function calculateDistance(point1:FlxPoint, point2:FlxPoint):Float {
        var dx:Float = point1.x - point2.x;
        var dy:Float = point1.y - point2.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}