package entities;

typedef StatModifier = Stats -> Void;

class Stats {
    public var maxHealth = 5;
    public var speed:Float = 75;

    public function new() {}

    public function copyTo(other:Stats) {
        other.maxHealth = maxHealth;
        other.speed = speed;
    }
}