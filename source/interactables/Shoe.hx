package interactables;

import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import entities.Player;
import flixel.math.FlxPoint;
import upgrades.SpeedClog;

class Shoe extends Interactable {

    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.SpeedClog();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [3]);
        animation.play("inventory");

        name = "SpeedClog";
        cost = 15;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.BOOT_BOUGHT, 1);
    }
}