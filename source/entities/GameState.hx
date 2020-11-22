package entities;

import upgrades.Upgrade;

class GameState {
    public var baseStats:Stats;
    public var upgradeMakers:Array<() -> Upgrade>;

    public function new() {
        baseStats = new Stats();
        baseStats.lightRadius = 100;
        baseStats.maxHealth = 5;
        baseStats.speed = 75;

        upgradeMakers = new Array<() -> Upgrade>();
    }
}