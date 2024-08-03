package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIGroup;
import haxe.Json;

class LevelEditorState extends FlxState {
    private var grid:FlxTypedGroup<FlxSprite>;
    private var waypoints:Array<FlxPoint>;
    private var waterTiles:Array<FlxPoint>;
    private var waves:Array<WaveData>;

    private var mode:String;
    private var waveGroup:FlxUIGroup;

    private var jsonText:FlxUIInputText;
    private var loadButton:FlxButton;
    private var saveButton:FlxButton;
    private var addWaypointButton:FlxButton;
    private var addWaterTileButton:FlxButton;
    private var addWaveButton:FlxButton;
    private var waypointLabel:FlxText;
    private var waterTileLabel:FlxText;
    private var waveInputs:Array<FlxUIInputText>;

    private var menuGroup:FlxUIGroup;

    override public function create():Void {
        super.create();
        grid = new FlxTypedGroup<FlxSprite>();
        waypoints = [];
        waterTiles = [];
        waves = [];
        mode = "waypoint";

        // Menu UI Elements
        menuGroup = new FlxUIGroup();
        menuGroup.scrollFactor.set();

        // Create grid
        createGrid();

        // UI Elements
        waypointLabel = new FlxText(10, 10, 200, "Waypoint Mode");
        waterTileLabel = new FlxText(10, 30, 200, "Water Tile Mode");
        waypointLabel.color = FlxColor.RED;
        waterTileLabel.color = FlxColor.WHITE;

        addWaypointButton = new FlxButton(10, 50, "Place Waypoint", switchToWaypointMode);
        addWaterTileButton = new FlxButton(10, 80, "Place Water Tile", switchToWaterTileMode);
        addWaveButton = new FlxButton(10, 110, "Add Wave", addWave);
        saveButton = new FlxButton(10, 140, "Save Level", saveLevel);
        loadButton = new FlxButton(10, 170, "Load Level", loadLevel);

        jsonText = new FlxUIInputText(10, 200, 150, "Enter JSON path", 40);

        waveGroup = new FlxUIGroup();
        waveInputs = [];

        menuGroup.add(waypointLabel);
        menuGroup.add(waterTileLabel);
        menuGroup.add(addWaypointButton);
        menuGroup.add(addWaterTileButton);
        menuGroup.add(addWaveButton);
        menuGroup.add(saveButton);
        menuGroup.add(loadButton);
        menuGroup.add(jsonText);

        add(menuGroup);
        add(waveGroup);
        add(grid);
    }

    private function createGrid():Void {
        for (i in 0...Std.int(FlxG.width / 32)) {
            for (j in 0...Std.int(FlxG.height / 32)) {
                var cell:FlxSprite = new FlxSprite(i * 32, j * 32);
                cell.makeGraphic(32, 32, FlxColor.TRANSPARENT);
                cell.scrollFactor.set();
                cell.alpha = 0.2;
                grid.add(cell);
            }
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.mouse.justPressedRight) {
            var gridPos:FlxPoint = new FlxPoint(Math.floor(FlxG.mouse.x / 32) * 32, Math.floor(FlxG.mouse.y / 32) * 32);

            if (isValidGridPosition(gridPos)) {
                if (mode == "waypoint") {
                    addWaypoint(gridPos);
                } else if (mode == "waterTile") {
                    addWaterTile(gridPos);
                }
            }
        }
    }

    private function isValidGridPosition(pos:FlxPoint):Bool {
        return pos.x >= 0 && pos.y >= 0 && pos.x < FlxG.width && pos.y < FlxG.height - 50; // Adjust 50 to match menu height
    }

    private function switchToWaypointMode():Void {
        mode = "waypoint";
        waypointLabel.color = FlxColor.RED;
        waterTileLabel.color = FlxColor.WHITE;
    }

    private function switchToWaterTileMode():Void {
        mode = "waterTile";
        waypointLabel.color = FlxColor.WHITE;
        waterTileLabel.color = FlxColor.RED;
    }

    private function addWaypoint(pos:FlxPoint):Void {
        var waypoint:FlxSprite = new FlxSprite(pos.x, pos.y);
        waypoint.makeGraphic(32, 32, FlxColor.GREEN);
        grid.add(waypoint);
        waypoints.push(new FlxPoint(pos.x, pos.y));
    }

    private function addWaterTile(pos:FlxPoint):Void {
        var waterTile:FlxSprite = new FlxSprite(pos.x, pos.y);
        waterTile.makeGraphic(32, 32, FlxColor.BLUE);
        grid.add(waterTile);
        waterTiles.push(new FlxPoint(pos.x, pos.y));
    }

    private function addWave():Void {
        var bloonCountInput:FlxUIInputText = new FlxUIInputText(10, waveGroup.y + waveGroup.height, 100, "Bloon Count");
        var spawnIntervalInput:FlxUIInputText = new FlxUIInputText(120, waveGroup.y + waveGroup.height, 100, "Spawn Interval");

        waveInputs.push(bloonCountInput);
        waveInputs.push(spawnIntervalInput);
        waveGroup.add(bloonCountInput);
        waveGroup.add(spawnIntervalInput);
    }

    private function saveLevel():Void {
        var waveData:Array<WaveData> = [];
        for (i in 0...Std.int(waveInputs.length / 2)) {
            var bloonCount:Int = Std.parseInt(waveInputs[i * 2].text);
            var spawnInterval:Float = Std.parseFloat(waveInputs[i * 2 + 1].text);
            waveData.push(new WaveData(bloonCount, spawnInterval));
        }

        var levelData:Dynamic = {
            waypoints: waypoints.map(function(p) return { x: p.x, y: p.y }),
            waterTiles: waterTiles.map(function(p) return { x: p.x, y: p.y }),
            waves: waveData
        };

        var json:String = Json.stringify(levelData);

        // Determine the path to the user's desktop
        var desktopPath:String;
        #if (windows)
            desktopPath = sys.io.Path.desktopDirectory + "level_data.json";
        #elseif (mac || linux)
            desktopPath = sys.io.Path.userHome + "/Desktop/level_data.json";
        #else
            desktopPath = sys.io.Path.userHome + "/Desktop/level_data.json";
        #end

        try {
            File.saveContent(desktopPath, json);
            FlxG.log("Level saved to desktop: " + desktopPath);
        } catch (e:Dynamic) {
            FlxG.log("Error saving level: " + e);
        }
    }

    private function loadLevel():Void {
        var json:String = sys.io.File.getContent(jsonText.text);
        var levelData:Dynamic = Json.parse(json);

        waypoints = [];
        waterTiles = [];
        waves = [];
        grid.clear();

        var waypointsArray:Array<Dynamic> = cast levelData.waypoints;
        for (point in waypointsArray) {
            addWaypoint(new FlxPoint(point.x, point.y));
        }

        var waterTilesArray:Array<Dynamic> = cast levelData.waterTiles;
        var waterTiles: Array<FlxPoint> = [];
         for (tile in waterTilesArray) {
            addWaterTile(new FlxPoint(tile.x, tile.y));
        }

        var wavesArray:Array<Dynamic> = cast levelData.waves;
        for (waveData in wavesArray) {
            waves.push(new WaveData(waveData.bloonCount, waveData.spawnInterval));
        }

         // Load waypoints
         waypoints = [];
         var waypointsArray:Array<Dynamic> = cast levelData.waypoints;
         for (point in waypointsArray) {
             waypoints.push(new FlxPoint(point.x, point.y));
         }
    }
}

class WaveData {
    public var bloonCount:Int;
    public var spawnInterval:Float;
    public function new(bloonCount:Int, spawnInterval:Float) {
        this.bloonCount = bloonCount;
        this.spawnInterval = spawnInterval;
    }
}