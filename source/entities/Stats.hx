package entities;

typedef StatModifier = Stats -> Void;

class Stats {
    public var lightRadius = 100;
    public var maxHealth = 5;
    public var speed = 75;

    public function new() {}

    public function copyTo(other:Stats) {
        other.lightRadius = lightRadius;
        other.maxHealth = maxHealth;
        other.speed = speed;
    }
}