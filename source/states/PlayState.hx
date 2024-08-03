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
import utils.Grid;
import haxe.Json;
import openfl.utils.Assets;

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Dynamic>; // Updated to hold different tower types
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var spreadProjectiles:FlxTypedGroup<SpreadProjectile>;
    private var sniperProjectiles:FlxTypedGroup<SniperProjectile>;
    private var moneyDrops:FlxTypedGroup<MoneyDrop>;
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
    private var grid:Grid;
    private var dragging:Bool = false;
    private var dragTower:FlxSprite;
    private var towerType:String;

    private var normalTowerSprite:FlxSprite;
    private var boomerangTowerSprite:FlxSprite;
    private var spreadTowerSprite:FlxSprite;
    private var moneyTowerSprite:FlxSprite;
    private var waterTowerSprite:FlxSprite;
    private var sniperTowerSprite:FlxSprite;

    override public function create():Void {
        instance = this;

        super.create();

        var cellSize:Int = 32;
        grid = new Grid(cellSize, Std.int(FlxG.width / cellSize), Std.int(FlxG.height / cellSize));

        // Define waypoints
        switch (LevelSelectState.curLevel)
        {
            case 0:
                loadLevel("assets/data/level1.json");
            case 1:
                loadLevel("assets/data/level2.json");
            case 2:
                loadLevel("assets/data/level3.json");
        }
         
        // Initialize groups
        bloons = new FlxTypedGroup<Bloon>();
        towers = new FlxTypedGroup<Tower>();
        projectiles = new FlxTypedGroup<Projectile>();
        boomerangProjectiles = new FlxTypedGroup<BoomerangProjectile>();
        spreadProjectiles = new FlxTypedGroup<SpreadProjectile>();
        sniperProjectiles = new FlxTypedGroup<SniperProjectile>();
        moneyDrops = new FlxTypedGroup<MoneyDrop>();

        livesText = new FlxText(10, 10, 200, "Lives: " + lives, 16);
        moneyText = new FlxText(10, 40, 200, "Money: " + money, 16);

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);
        add(spreadProjectiles);
        add(sniperProjectiles);
        add(moneyDrops);

        add(livesText);
        add(moneyText);

        // Create UI sprites for towers
        createTowerSprites();
    }

    private function loadLevel(jsonPath:String):Void {
        var json:String = Assets.getText(jsonPath);
        var levelData:Dynamic = Json.parse(json);
    
        // Load waypoints
        waypoints = [];
        var waypointsArray:Array<Dynamic> = cast levelData.waypoints;
        for (point in waypointsArray) {
            waypoints.push(new FlxPoint(point.x, point.y));
        }
    
        // Load water tiles
        var waterTilesArray:Array<Dynamic> = cast levelData.waterTiles;
        var waterTiles: Array<FlxPoint> = [];
        for (tile in waterTilesArray) {
            waterTiles.push(new FlxPoint(tile.x, tile.y));
            grid.setTileType(tile.x, tile.y, TileType.WATER);
        }
    
        // Load waves
        waves = [];
        var wavesArray:Array<Dynamic> = cast levelData.waves;
        for (waveData in wavesArray) {
            waves.push(new Wave(waveData.bloonCount, waveData.spawnInterval, 1, waypoints));
        }
    
        // Draw waypoints and lines between them
        drawWaypointsAndLines();
        drawWaterTiles(waterTiles);
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        livesText.text = "Lives: " + lives;
        moneyText.text = "Money: " + money;

         // Handle dragging and dropping towers
         if (dragging) {
            dragTower.x = FlxG.mouse.x - dragTower.width / 2;
            dragTower.y = FlxG.mouse.y - dragTower.height / 2;

            if (FlxG.mouse.justReleased) {
                var gridPos:FlxPoint = grid.worldToGrid(dragTower.x, dragTower.y);

                if (towerType == "Normal" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 50) {
                    money -= 50;
                    var tower = new Tower(dragTower.x, dragTower.y, projectiles);
                    towers.add(tower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Boomerang" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 75) {
                    money -= 75;
                    var boomerangTower = new BoomerangTower(dragTower.x, dragTower.y, boomerangProjectiles);
                    towers.add(boomerangTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Spread" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 125) {
                    money -= 125;
                    var spreadTower = new SpreadTower(dragTower.x, dragTower.y, spreadProjectiles);
                    towers.add(spreadTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Money" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 200) {
                    money -= 200;
                    var moneyTower = new MoneyTower(dragTower.x, dragTower.y, moneyDrops);
                    towers.add(moneyTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Water" && grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.WATER && money >= 75) {
                    money -= 75;
                    var waterTower = new WaterTower(dragTower.x, dragTower.y, projectiles);
                    towers.add(waterTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Sniper" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 300) {
                    money -= 300;
                    var sniperTower = new SniperTower(dragTower.x, dragTower.y, sniperProjectiles);
                    towers.add(sniperTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else {
                    // Invalid placement, cancel dragging
                    dragging = false;
                    dragTower.kill();
                }
            }
        } else {
            checkTowerSelection();
        }

        // Check for collisions between towers and bloons
        for (tower in towers) {
            tower.checkCollision(bloons, elapsed);
        }

        handleWaves(elapsed);
    }

    private function markPathAsOccupied(start:FlxPoint, end:FlxPoint):Void {
        var startX:Int = Math.floor(start.x / grid.cellSize);
        var startY:Int = Math.floor(start.y / grid.cellSize);
        var endX:Int = Math.floor(end.x / grid.cellSize);
        var endY:Int = Math.floor(end.y / grid.cellSize);

        if (startX == endX) {
            for (y in Std.int(Math.min(startY, endY))...Std.int(Math.max(startY, endY) + 1)) {
                grid.setTileType(startX, y, TileType.PATH);
            }
        } else if (startY == endY) {
            for (x in Std.int(Math.min(startX, endX))...Std.int(Math.max(startX, endX) + 1)) {
                grid.setTileType(x, startY, TileType.PATH);
            }
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

    private function drawWaterTiles(waterTiles:Array<FlxPoint>):Void {
        for (tile in waterTiles) {
            var waterTile:FlxSprite = new FlxSprite(tile.x * grid.cellSize, tile.y * grid.cellSize);
            waterTile.makeGraphic(grid.cellSize, grid.cellSize, 0x00D9FF);
            add(waterTile);
        }
    }

    private function createTowerSprites():Void {
        normalTowerSprite = new FlxSprite(10, FlxG.height - 50);
        normalTowerSprite.scrollFactor.set();
        normalTowerSprite.makeGraphic(48, 48, FlxColor.BLUE);
        add(normalTowerSprite);

        boomerangTowerSprite = new FlxSprite(70, FlxG.height - 50);
        boomerangTowerSprite.scrollFactor.set();
        boomerangTowerSprite.makeGraphic(48, 48, FlxColor.GRAY);
        add(boomerangTowerSprite);

        spreadTowerSprite = new FlxSprite(130, FlxG.height - 50);
        spreadTowerSprite.scrollFactor.set();
        spreadTowerSprite.makeGraphic(48, 48, FlxColor.PINK);
        add(spreadTowerSprite);

        moneyTowerSprite = new FlxSprite(190, FlxG.height - 50);
        moneyTowerSprite.scrollFactor.set();
        moneyTowerSprite.makeGraphic(48, 48, 0xff00ff00);
        add(moneyTowerSprite);

        waterTowerSprite = new FlxSprite(250, FlxG.height - 50);
        waterTowerSprite.scrollFactor.set();
        waterTowerSprite.makeGraphic(48, 48, FlxColor.BROWN);
        add(waterTowerSprite);

        sniperTowerSprite = new FlxSprite(310, FlxG.height - 50);
        sniperTowerSprite.scrollFactor.set();
        sniperTowerSprite.makeGraphic(48, 48, 0xFF78866b);
        add(sniperTowerSprite);
    }

    private function checkTowerSelection():Void {
        if (normalTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Normal");
        } else if (boomerangTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Boomerang");
        } else if (spreadTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Spread");
        } else if (moneyTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Money");
        } else if (waterTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Water");
        } else if (sniperTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition()) && FlxG.mouse.justPressed) {
            startDraggingTower("Sniper");
        }
    }

    private function startDraggingTower(type:String):Void {
        dragging = true;
        towerType = type;
        dragTower = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
        dragTower.makeGraphic(32, 32, 0x55ffffff); // Semi-transparent white for dragging
        add(dragTower);
    }
}