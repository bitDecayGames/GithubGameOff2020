package entities;

import upgrades.Upgrade;

class GameState {
    public var baseStats:Stats;
    public var money:Int = 5;
    public var upgradeMakers:Array<() -> Upgrade>;

    public function new() {
        baseStats = new Stats();
        baseStats.maxHealth = 5;
        baseStats.speed = 75;

        upgradeMakers = new Array<() -> Upgrade>();
    }
}