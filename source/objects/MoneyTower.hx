package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;


class MoneyTower extends FlxSprite {
    public var productionRate:Float = 5; // Time in seconds to produce money
    private var timeSinceLastProduction:Float = 0;
    private var moneyDrops:FlxTypedGroup<MoneyDrop>;
    private var dropPosistions:Array<Float> = [-30, 60, 30, -60];

    public function new(x:Float, y:Float, moneyDrops:FlxTypedGroup<MoneyDrop>) {
        super(x, y);
        
        this.moneyDrops = moneyDrops;
        
        // Set tower graphic
        makeGraphic(32, 32, 0xff00ff00);
    }

    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {}

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        timeSinceLastProduction += elapsed;

        if (timeSinceLastProduction >= productionRate) {
            produceMoney();
            timeSinceLastProduction = 0;
        }
    }

    private function produceMoney():Void {
        var moneyDrop = new MoneyDrop(x + FlxG.random.float(-60, 60), y + FlxG.random.float(-60, 60));
        moneyDrops.add(moneyDrop);
    }
}
