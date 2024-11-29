package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import utils.Upgrade;

class Tower extends FlxSprite {
    public var level:Int = 1;
    public var upgrades:Array<Upgrade>;
    public var damage:Int = 1;
    public var fireRate:Float = 1.0; // Time in seconds between shots
    public var range:Float = 100;
    private var timeSinceLastShot:Float = 0;
    private var projectiles:FlxTypedGroup<Dynamic>; // Accept both types of projectiles

    public function new(X:Float, Y:Float, projectilesGroup:FlxTypedGroup<Dynamic>) {
        super(X, Y);
        makeGraphic(32, 32, FlxColor.WHITE);
        projectiles = projectilesGroup;

        replaceColor(FlxColor.WHITE, FlxColor.BLUE);
        level = 1;

        upgrades = [
            new Upgrade(100, 2, 120, 0.8), // Level 2: cost, newDamage, newRange, newFireRate
            new Upgrade(200, 3, 150, 0.6),  // Level 3
            new Upgrade(200, 3, 150, 0.6),  // Level 3
        ];
    }
    
    public function checkCollision(bloons:FlxTypedGroup<Bloon>, elapsed:Float):Void {
        timeSinceLastShot += elapsed;

        if (timeSinceLastShot >= fireRate) {
            var target:Bloon = findClosestBloon(bloons);
            if (target != null && calculateDistance(new FlxPoint(x, y), target) < range) {
                shoot(target);
                timeSinceLastShot = 0;
            }
        }
    }

    private function findClosestBloon(bloons:FlxTypedGroup<Bloon>):Bloon {
        var closest:Bloon = null;
        var closestDist:Float = Math.POSITIVE_INFINITY;
        
        for (bloon in bloons) {
            if (bloon.exists) {
                var dist:Float = calculateDistance(new FlxPoint(x, y), bloon);
                if (dist < closestDist) {
                    closestDist = dist;
                    closest = bloon;
                }
            }
        }
        
        return closest;
    }

    private function calculateDistance(point:FlxPoint, bloon:Bloon):Float {
        var dx:Float = point.x - bloon.x;
        var dy:Float = point.y - bloon.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function shoot(target:Bloon):Void {
        var projectile:Dynamic;
        projectile = new Projectile(x, y, target, damage);
        projectiles.add(projectile);
    }

    public function upgradeTower():Bool {
        if (level < upgrades.length && states.PlayState.instance.money >= upgrades[level - 1].cost) {
            var upgrade:Upgrade = upgrades[level - 1];
            damage = upgrade.newDamage;
            range = upgrade.newRange;
            fireRate = upgrade.newFireRate;
            states.PlayState.instance.money -= upgrade.cost;
            level++;
             // Change the tower's sprite for the new level
            switch(level) {
                case 2:
                    replaceColor(FlxColor.BLUE, FlxColor.CYAN);
                case 3:
                    replaceColor(FlxColor.CYAN, FlxColor.PINK);
            }
            return true;
        }
        return false;
    }
}