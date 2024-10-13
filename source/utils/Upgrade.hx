package utils;

class Upgrade {
    public var cost:Int;
    public var newDamage:Int;
    public var newRange:Float;
    public var newFireRate:Float;
    
    public function new(cost:Int, newDamage:Int, newRange:Float, newFireRate:Float) {
        this.cost = cost;
        this.newDamage = newDamage;
        this.newRange = newRange;
        this.newFireRate = newFireRate;
    }
}