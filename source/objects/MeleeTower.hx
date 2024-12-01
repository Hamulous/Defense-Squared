package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class MeleeTower extends FlxSprite {
    public var range:Float; // Range of the melee tower
    public var damage:Int; // Damage dealt to bloons
    public var attackCooldown:Float; // Time between attacks
    private var attackTimer:Float = 0; // Timer to track attack cooldown

    public function new(x:Float, y:Float) {
        super(x, y);

        makeGraphic(32, 32, 0xFF54204f); // Representing the tower

        range = 50;         // Example range
        damage = 1;         // Example damage
        attackCooldown = 1; // 1 second cooldown
    }

    public function checkAndAttack(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        attackTimer += elapsed;

        // Only attack if cooldown is complete
        if (attackTimer < attackCooldown) return;

        for (bloon in bloons.members) {
            if (bloon == null || !bloon.exists) continue;

            var distance = calculateDistance(this, bloon);
            if (distance <= range) {
                // Attack the bloon
                bloon.takeDamage(damage);
                attackTimer = 0; // Reset the cooldown
                return; // Attack one bloon per cycle
            }
        }
    }

    private function calculateDistance(sprite1:FlxSprite, sprite2:FlxSprite):Float {
        var dx = sprite2.x + sprite2.width / 2 - (sprite1.x + sprite1.width / 2);
        var dy = sprite2.y + sprite2.height / 2 - (sprite1.y + sprite1.height / 2);
        return Math.sqrt(dx * dx + dy * dy);
    }

    public function drawRange(parentGroup:FlxTypedGroup<FlxSprite>):Void {
        var rangeSprite:FlxSprite = new FlxSprite(x - range, y - range);
        rangeSprite.makeGraphic(Std.int(range * 2), Std.int(range * 2), FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawCircle(rangeSprite, range, {thickness: 2, color: FlxColor.YELLOW});
        parentGroup.add(rangeSprite);
    }
}
