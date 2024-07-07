package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import objects.*;

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Dynamic>; // Updated to hold different tower types
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var spreadProjectiles:FlxTypedGroup<SpreadProjectile>;
    private var waypoints:Array<FlxPoint>;

    override public function create():Void {
        super.create();

        // Define waypoints
        waypoints = [
            new FlxPoint(100, 300),
            new FlxPoint(300, 300),
            new FlxPoint(300, 100),
            new FlxPoint(500, 100),
            new FlxPoint(500, 300),
            new FlxPoint(700, 300)
        ];

        // Draw waypoints and lines between them
        drawWaypointsAndLines();
         
        // Initialize groups
        bloons = new FlxTypedGroup<Bloon>();
        towers = new FlxTypedGroup<Tower>();
        projectiles = new FlxTypedGroup<Projectile>();
        boomerangProjectiles = new FlxTypedGroup<BoomerangProjectile>();
        spreadProjectiles = new FlxTypedGroup<SpreadProjectile>();

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);
        add(spreadProjectiles);

        // Add some bloons for testing
        for (i in 0...5) {
            var bloon = new Bloon(waypoints, 0);
            bloon.x -= (i * 100);
            bloons.add(bloon);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Add a button to add towers
        if (FlxG.mouse.justPressed)
        {
            var tower = new Tower(FlxG.mouse.x, FlxG.mouse.y, projectiles);
            towers.add(tower);
        } else if (FlxG.mouse.justPressedRight) {
            var boomerangTower = new BoomerangTower(FlxG.mouse.x, FlxG.mouse.y, boomerangProjectiles);
            towers.add(boomerangTower);
        } else if (FlxG.mouse.justPressedMiddle) {
            var spreadTower = new SpreadTower(FlxG.mouse.x, FlxG.mouse.y, spreadProjectiles);
            towers.add(spreadTower);
        }

        // Check for collisions between towers and bloons
        for (tower in towers) {
            tower.checkCollision(bloons, elapsed);
        }
    }

    private function drawWaypointsAndLines():Void {
        for (i in 0...waypoints.length - 1) {
            var line:FlxSprite = new FlxSprite();
            line.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
            FlxSpriteUtil.drawLine(line, waypoints[i].x, waypoints[i].y, waypoints[i + 1].x, waypoints[i + 1].y, {thickness:24, color:0xffffffff}, {smoothing:true});
            add(line);
        }

        for (point in waypoints) {
            var waypoint:FlxSprite = new FlxSprite(point.x - 2, point.y - 2);
            waypoint.makeGraphic(4, 4, FlxColor.GREEN);
            add(waypoint);
        }
    }
}