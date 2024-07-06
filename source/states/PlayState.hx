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
import utils.Wave;

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Dynamic>; // Updated to hold different tower types
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var waypoints:Array<FlxPoint>;

    private var waves:Array<Wave>;
    private var currentWaveIndex:Int = 0;
    private var timeSinceLastWave:Float = 0;
    private var timeSinceLastSpawn:Float = 0;
    private var bloonsRemainingInWave:Int = 0;

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

        // Define waves
        waves = [
            new Wave(5, 1, 1, waypoints),
            new Wave(10, 1, 1, waypoints),
            new Wave(20, 1, 1, waypoints)
        ];

        // Initialize groups
        bloons = new FlxTypedGroup<Bloon>();
        towers = new FlxTypedGroup<Tower>();
        projectiles = new FlxTypedGroup<Projectile>();
        boomerangProjectiles = new FlxTypedGroup<BoomerangProjectile>();

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Add a button to add towers
        if (FlxG.mouse.justPressedMiddle) {
            var tower = new Tower(FlxG.mouse.x, FlxG.mouse.y, projectiles, false);
            towers.add(tower);
        } else if (FlxG.mouse.justPressed){
            var spreadTower:SpreadTower = new SpreadTower(FlxG.mouse.x, FlxG.mouse.y, projectiles);
            towers.add(spreadTower);
        } else if (FlxG.mouse.justPressedRight) {
            var boomerangTower = new Tower(FlxG.mouse.x, FlxG.mouse.y, boomerangProjectiles, true);
            towers.add(boomerangTower);
        }

        // Check for collisions between towers and bloons
        for (tower in towers) {
            tower.checkCollision(bloons, elapsed);
        }

        for (projectile in projectiles) {
            for (bloon in bloons) {
                if (projectile.overlaps(bloon)) {
                    bloon.takeDamage(1);
                    projectile.kill();
                }
            }
        }

        handleWaves(elapsed);
    }

    private function handleWaves(elapsed:Float):Void {
        if (currentWaveIndex >= waves.length) {
            return; // All waves completed
        }

        timeSinceLastWave += elapsed;

        if (bloonsRemainingInWave <= 0) {
            if (currentWaveIndex < waves.length) {
                bloonsRemainingInWave = waves[currentWaveIndex].bloonCount;
                timeSinceLastWave = 0;
                timeSinceLastSpawn = 0;
            }
        } else {
            timeSinceLastSpawn += elapsed;

            if (timeSinceLastSpawn >= waves[currentWaveIndex].spawnInterval) {
                var bloon:Bloon = waves[currentWaveIndex].spawnBloon();
                bloons.add(bloon);
                bloonsRemainingInWave--;
                timeSinceLastSpawn = 0;
            }

            if (bloonsRemainingInWave <= 0) {
                currentWaveIndex++;
            }
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