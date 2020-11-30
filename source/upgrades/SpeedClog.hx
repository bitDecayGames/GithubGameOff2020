package upgrades;

import entities.Stats;

class SpeedClog extends Upgrade {
    public function new() {
        super();
        name = "SpeedClog";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [15]);
        animation.play("inventory");
    }

    override public function modifier(stats:Stats) {
        stats.speed += 10;
    }

    override public function getDescription():String {
        return "10 speed";
    }
}