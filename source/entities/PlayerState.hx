package entities;

import upgrades.Upgrade;

class PlayerState {
    public var baseStats:Stats;
    public var upgrades:Array<Upgrade>;

    public function new() {
        baseStats = new Stats();
        baseStats.lightRadius = 100;
        baseStats.maxHealth = 5;
        baseStats.speed = 75;

        upgrades = new Array<Upgrade>();
    }
}