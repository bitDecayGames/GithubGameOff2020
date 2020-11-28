package entities;

import upgrades.Upgrade;

class GameState {
    public var baseStats:Stats;
    public var activeStats:Stats;

    public var money:Int = 5;
    public var upgradeMakers:Array<() -> Upgrade>;

    public function new() {
        baseStats = new Stats();
        baseStats.maxHealth = 5;
        baseStats.speed = 75;

        activeStats = new Stats();

        upgradeMakers = new Array<() -> Upgrade>();
    }
}