package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

class SpreadProjectile extends FlxSprite {
    public function new(X:Float, Y:Float, velocityX:Float, velocityY:Float) {
        super(X, Y);
        makeGraphic(8, 8, FlxColor.YELLOW);
        velocity.set(velocityX, velocityY);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Optional: Add logic to remove the projectile after a certain time or when it goes off screen
        if (x < 0 || x > FlxG.width || y < 0 || y > FlxG.height) {
            kill();
        }
    }
}