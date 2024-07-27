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

class PlayState extends FlxState {
    private var bloons:FlxTypedGroup<Bloon>;
    private var towers:FlxTypedGroup<Dynamic>; // Updated to hold different tower types
    private var projectiles:FlxTypedGroup<Projectile>;
    private var boomerangProjectiles:FlxTypedGroup<BoomerangProjectile>;
    private var spreadProjectiles:FlxTypedGroup<SpreadProjectile>;
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


    override public function create():Void {
        instance = this;

        super.create();

        var cellSize:Int = 32;
        grid = new Grid(cellSize, Std.int(FlxG.width / cellSize), Std.int(FlxG.height / cellSize));

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

        // Mark waypoints and paths as occupied in the grid
        for (i in 0...waypoints.length - 1) {
            var start:FlxPoint = waypoints[i];
            var end:FlxPoint = waypoints[i + 1];
            markPathAsOccupied(start, end);
        }

         // Define water tiles
         var waterTiles = [
            new FlxPoint(10, 10),
            new FlxPoint(11, 10),
            new FlxPoint(12, 10),
            new FlxPoint(13, 10)
        ];

        // Mark water tiles in the grid
        for (tile in waterTiles) {
            grid.setTileType(Std.int(tile.x), Std.int(tile.y), TileType.WATER);
        }
       
        // Draw waypoints and lines between them
        drawWaypointsAndLines();
        drawWaterTiles(waterTiles);

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
        moneyDrops = new FlxTypedGroup<MoneyDrop>();

        livesText = new FlxText(10, 10, 200, "Lives: " + lives, 16);
        moneyText = new FlxText(10, 40, 200, "Money: " + money, 16);

        add(bloons);
        add(towers);
        add(projectiles);
        add(boomerangProjectiles);
        add(spreadProjectiles);
        add(moneyDrops);

        add(livesText);
        add(moneyText);

        // Create UI sprites for towers
        createTowerSprites();

        //var moneyTower = new MoneyTower(300, 500, moneyDrops);
        //towers.add(moneyTower);
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
                } else if (towerType == "Money" && grid.isTileAvailable(Std.int(gridPos.x), Std.int(gridPos.y)) && money >= 125) {
                    money -= 200;
                    var moneyTower = new MoneyTower(dragTower.x, dragTower.y, moneyDrops);
                    towers.add(moneyTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                    dragging = false;
                    dragTower.kill();
                } else if (towerType == "Water" && grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.WATER && money >= 125) {
                    money -= 75;
                    var waterTower = new WaterTower(dragTower.x, dragTower.y, projectiles);
                    towers.add(waterTower);
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

    private function placeTower(towerType:Int):Void {
        switch(towerType)
        {
            case 0:
                var gridPos:FlxPoint = grid.worldToGrid(FlxG.mouse.x, FlxG.mouse.y);
                if (grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.EMPTY && money >= 50) {
                    money -= 50;
                    var tower = new Tower(FlxG.mouse.x, FlxG.mouse.y, projectiles);
                    towers.add(tower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                }
            case 1:
                var gridPos:FlxPoint = grid.worldToGrid(FlxG.mouse.x, FlxG.mouse.y);
                if (grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.EMPTY && money >= 75) {
                    money -= 75;
                    var boomerangTower = new BoomerangTower(FlxG.mouse.x, FlxG.mouse.y, boomerangProjectiles);
                    towers.add(boomerangTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                }
            case 2:
                var gridPos:FlxPoint = grid.worldToGrid(FlxG.mouse.x, FlxG.mouse.y);
                if (grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.EMPTY && money >= 125) {
                    money -= 125;
                    var spreadTower = new SpreadTower(FlxG.mouse.x, FlxG.mouse.y, spreadProjectiles);
                    towers.add(spreadTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                }     
            case 3:
                var gridPos:FlxPoint = grid.worldToGrid(FlxG.mouse.x, FlxG.mouse.y);
                if (grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.EMPTY && money >= 200) {
                    money -= 200;
                    var moneyTower = new MoneyTower(FlxG.mouse.x, FlxG.mouse.y, moneyDrops);
                    towers.add(moneyTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                }
            case 4:
                var gridPos:FlxPoint = grid.worldToGrid(FlxG.mouse.x, FlxG.mouse.y);
                if (grid.getTileType(Std.int(gridPos.x), Std.int(gridPos.y)) == TileType.WATER && money >= 75) {
                    money -= 75;
                    var waterTower = new WaterTower(FlxG.mouse.x, FlxG.mouse.y, projectiles);
                    towers.add(waterTower);
                    grid.setTileType(Std.int(gridPos.x), Std.int(gridPos.y), TileType.OCCUPIED);
                }
        }
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
            waterTile.makeGraphic(grid.cellSize, grid.cellSize, FlxColor.BLUE);
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
    }

    private function checkTowerSelection():Void {
        if (normalTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            startDraggingTower("Normal");
        } else if (boomerangTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            startDraggingTower("Boomerang");
        } else if (spreadTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            startDraggingTower("Spread");
        } else if (moneyTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            startDraggingTower("Money");
        } else if (waterTowerSprite.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            startDraggingTower("Water");
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