package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import objects.*;

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Tower>;
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var waypoints:Array<FlxPoint>;

    override public function create():Void {
        super.create();

        // Initialize groups
        bloons = new FlxTypedGroup<Bloon>();
        towers = new FlxTypedGroup<Tower>();
        projectiles = new FlxTypedGroup<Projectile>();
        boomerangProjectiles = new FlxTypedGroup<BoomerangProjectile>();

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);

        // Define waypoints
        waypoints = [
            new FlxPoint(100, 300),
            new FlxPoint(300, 300),
            new FlxPoint(300, 100),
            new FlxPoint(500, 100),
            new FlxPoint(500, 300),
            new FlxPoint(700, 300)
        ];

        // Add some bloons for testing
        for (i in 0...5) {
            var bloon = new Bloon(waypoints, 0);
            bloon.x -= (i * 100);
            bloons.add(bloon);
        }

        // Add a tower
        var tower = new Tower(400, 300, projectiles, false);
        towers.add(tower);

        var boomerangTower = new Tower(400, 700, boomerangProjectiles, true);
        towers.add(boomerangTower);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Add a button to add towers
        if (FlxG.mouse.justPressed)
        {
            var tower = new Tower(FlxG.mouse.x, FlxG.mouse.y, projectiles, false);
            towers.add(tower);
        } else if (FlxG.mouse.justPressedRight) {
            var boomerangTower = new Tower(FlxG.mouse.x, FlxG.mouse.y, boomerangProjectiles, true);
            towers.add(boomerangTower);
        }

        // Check for collisions between towers and bloons
        for (tower in towers) {
            tower.checkCollision(bloons, elapsed);
        }
    }
}