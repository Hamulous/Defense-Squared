package utils;

import flixel.math.FlxPoint;

enum TileType {
    EMPTY;
    OCCUPIED;
    PATH;
    WATER;
}

class Grid {
    public var cellSize:Int;
    public var cols:Int;
    public var rows:Int;
    private var tiles:Array<Array<TileType>>;

   public function new(cellSize:Int, cols:Int, rows:Int) {
        this.cellSize = cellSize;
        this.cols = cols;
        this.rows = rows;
        tiles = new Array<Array<TileType>>();

        for (y in 0...rows) {
            var row = new Array<TileType>();
            for (x in 0...cols) {
                row.push(TileType.EMPTY);
            }
            tiles.push(row);
        }
    }

    public function worldToGrid(worldX:Float, worldY:Float):FlxPoint {
        var gridX = Math.floor(worldX / cellSize);
        var gridY = Math.floor(worldY / cellSize);
        return new FlxPoint(gridX, gridY);
    }

    public function gridToWorld(gridX:Int, gridY:Int):FlxPoint {
        var worldX = gridX * cellSize;
        var worldY = gridY * cellSize;
        return new FlxPoint(worldX, worldY);
    }

    public function getTileType(gridX:Int, gridY:Int):TileType {
        return tiles[gridY][gridX];
    }

    public function setTileType(gridX:Int, gridY:Int, type:TileType):Void {
        tiles[gridY][gridX] = type;
    }

    public function getData():Array<Array<TileType>> {
        return tiles;
    }

    public function setData(data:Array<Array<TileType>>):Void {
        tiles = data;
    }

    public function clear():Void {
        for (y in 0...rows) {
            for (x in 0...cols) {
                tiles[y][x] = TileType.EMPTY;
            }
        }
    }
}