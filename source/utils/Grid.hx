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
    public var width:Int;
    public var height:Int;
    private var cells:Array<Array<TileType>>;

    public function new(cellSize:Int, width:Int, height:Int) {
        this.cellSize = cellSize;
        this.width = width;
        this.height = height;
        cells = new Array<Array<TileType>>();

        for (i in 0...width) {
            cells[i] = new Array<TileType>();
            for (j in 0...height) {
                cells[i][j] = TileType.EMPTY;
            }
        }
    }

    public function setTileType(x:Int, y:Int, type:TileType):Void {
        cells[x][y] = type;
    }

    public function getTileType(x:Int, y:Int):TileType {
        return cells[x][y];
    }

    public function worldToGrid(x:Float, y:Float):FlxPoint {
        return new FlxPoint(Math.floor(x / cellSize), Math.floor(y / cellSize));
    }

    public function gridToWorld(gridX:Int, gridY:Int):FlxPoint {
        return new FlxPoint(gridX * cellSize, gridY * cellSize);
    }
}