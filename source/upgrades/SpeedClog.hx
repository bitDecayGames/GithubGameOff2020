package upgrades;

import entities.Stats;

class SpeedClog extends Upgrade {
    public function new() {
        super();

        loadGraphic(AssetPaths.speedClog__png, 16, 16);
    }

    override public function modifier(stats:Stats) {
        stats.speed += 20;
    }
}