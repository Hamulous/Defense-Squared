package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import objects.*;
import utils.Wave;

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Dynamic>; // Updated to hold different tower types
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var spreadProjectiles:FlxTypedGroup<SpreadProjectile>;
    private var waypoints:Array<FlxPoint>;

    private var waves:Array<Wave>;
    private var currentWaveIndex:Int = 0;
    private var timeSinceLastWave:Float = 0;
    private var timeSinceLastSpawn:Float = 0;
    public var bloonsRemainingInWave:Int = 0;
    public var bloonsActive:Int = 0;

    private var livesText:FlxText;
    private var moneyText:FlxText;
    public var lives:Int = 100;
    public var money:Int = 650;

    public static var instance:PlayState;
    private var curSelected:Int = 0;

    override public function create():Void {
        instance = this;

        super.create();

        // Define waypoints
        switch (LevelSelectState.curLevel)
        {
            case 0:
                waypoints = [
                    new FlxPoint(0, 300), new FlxPoint(100, 300), new FlxPoint(100, 200),
                    new FlxPoint(200, 200), new FlxPoint(200, 400), new FlxPoint(300, 400),
                    new FlxPoint(300, 100), new FlxPoint(400, 100), new FlxPoint(400, 300),
                    new FlxPoint(500, 300), new FlxPoint(500, 500), new FlxPoint(600, 500),
                    new FlxPoint(600, 200), new FlxPoint(700, 200), new FlxPoint(700, 400),
                    new FlxPoint(800, 400), new FlxPoint(800, 300), new FlxPoint(950, 300)
                ];
            case 1:
                waypoints = [
                    new FlxPoint(0, 300),
                    new FlxPoint(100, 300),
                    new FlxPoint(100, 200),
                    new FlxPoint(200, 200),
                    new FlxPoint(200, 400),
                    new FlxPoint(300, 400),
                    new FlxPoint(300, 100),
                    new FlxPoint(400, 100),
                    new FlxPoint(400, 300),
                    new FlxPoint(500, 300),
                    new FlxPoint(500, 200),
                    new FlxPoint(600, 200),
                    new FlxPoint(600, 400),
                    new FlxPoint(700, 400),
                    new FlxPoint(700, 300)
                ];
            case 2:
                waypoints = [
                    new FlxPoint(0, 300),
                    new FlxPoint(100, 300),
                    new FlxPoint(100, 200),
                    new FlxPoint(200, 200),
                    new FlxPoint(200, 400),
                    new FlxPoint(300, 400),
                    new FlxPoint(300, 100),
                    new FlxPoint(400, 100),
                    new FlxPoint(400, 300),
                    new FlxPoint(500, 300),
                    new FlxPoint(500, 100),
                    new FlxPoint(600, 100),
                    new FlxPoint(600, 400),
                    new FlxPoint(700, 400),
                    new FlxPoint(700, 200),
                    new FlxPoint(800, 200)
                ];
        }
       
        // Draw waypoints and lines between them
        drawWaypointsAndLines();

        // Define waves
        waves = [
            new Wave(5, 1, 1, waypoints),
            new Wave(10, 1, 1, waypoints),
            new Wave(20, 1, 1, waypoints),
            new Wave(20, 1, 1, waypoints) //Dummy wave I guess 
        ];
         
        // Initialize groups
        bloons = new FlxTypedGroup<Bloon>();
        towers = new FlxTypedGroup<Tower>();
        projectiles = new FlxTypedGroup<Projectile>();
        boomerangProjectiles = new FlxTypedGroup<BoomerangProjectile>();
        spreadProjectiles = new FlxTypedGroup<SpreadProjectile>();

        livesText = new FlxText(10, 10, 200, "Lives: " + lives, 16);
        moneyText = new FlxText(10, 40, 200, "Money: " + money, 16);

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);
        add(spreadProjectiles);

        add(livesText);
        add(moneyText);

        changeTowerSelect();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.RIGHT)
            changeTowerSelect(1);
        else if (FlxG.keys.justPressed.LEFT)
            changeTowerSelect(-1);

        livesText.text = "Lives: " + lives;
        moneyText.text = "Money: " + money;

        if (FlxG.mouse.justPressed) {
            placeTower(curSelected);
        }

        // Check for collisions between towers and bloons
        for (tower in towers) {
            tower.checkCollision(bloons, elapsed);
        }

        handleWaves(elapsed);
    }

    function changeTowerSelect(change:Int = 0):Void {
        curSelected += change;

        if (curSelected < 0)
            curSelected = 2;
        if (curSelected >= 3)
            curSelected = 0;

        trace('Changed' + curSelected);
    }

    private function placeTower(towerType:Int):Void {
        switch(towerType)
        {
            case 0:
                var tower = new Tower(FlxG.mouse.x, FlxG.mouse.y, projectiles);
                towers.add(tower);
            case 1:
                var boomerangTower = new BoomerangTower(FlxG.mouse.x, FlxG.mouse.y, boomerangProjectiles);
                towers.add(boomerangTower);
            case 2:
                var spreadTower = new SpreadTower(FlxG.mouse.x, FlxG.mouse.y, spreadProjectiles);
                towers.add(spreadTower);
        }
    }

    private function handleWaves(elapsed:Float):Void {
        if (currentWaveIndex >= waves.length) {
            return; // All waves completed
        }

        timeSinceLastWave += elapsed;

        if (bloonsRemainingInWave <= 0 && bloonsActive <= 0) {
            if (currentWaveIndex < waves.length) {
                bloonsRemainingInWave = waves[currentWaveIndex].bloonCount;
                bloonsActive = bloonsRemainingInWave; // Initialize the active bloons count
                timeSinceLastWave = 0;
                timeSinceLastSpawn = 0;
                currentWaveIndex++;
                trace('NEXT WAVE');
            }
        } else {
            timeSinceLastSpawn += elapsed;

            if (timeSinceLastSpawn >= waves[currentWaveIndex].spawnInterval && bloonsRemainingInWave > 0) {
                var bloon:Bloon = waves[currentWaveIndex].spawnBloon();
                bloons.add(bloon);
                timeSinceLastSpawn = 0;
                bloonsRemainingInWave--;
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