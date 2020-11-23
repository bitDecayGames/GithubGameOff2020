package entities;

typedef StatModifier = Stats -> Void;

class Stats {
    public var lightRadius:Float = 100;
    public var minLightRadius:Float = 15;
    public var lightDrainRate:Float = 2; // units per second
    public var maxHealth = 5;
    public var speed:Float = 75;

    public function new() {}

    public function copyTo(other:Stats) {
        other.lightRadius = lightRadius;
        other.lightDrainRate = lightDrainRate;
        other.maxHealth = maxHealth;
        other.speed = speed;
    }
}