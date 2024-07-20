package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import states.PlayState;

class MoneyDrop extends FlxSprite {
    public var value:Int = 50;

    public function new(x:Float, y:Float) {
        super(x, y);

        // Set money drop graphic
        makeGraphic(24, 24, 0xffffd700); // Gold color
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (overlapsPoint(FlxG.mouse.getScreenPosition())) {
            if (FlxG.mouse.justPressed) {
                collect();
            }
        }
    }

    private function collect():Void {
        PlayState.instance.money += value;
        kill();
    }
}
