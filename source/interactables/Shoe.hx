package interactables;

import flixel.text.FlxText;
import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import entities.Player;
import flixel.math.FlxPoint;
import upgrades.SpeedClog;

class Shoe extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.SpeedClog();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [3]);
        animation.play("inventory");

        name = "SpeedClog";
        cost = 15;

        priceText = new FlxText(_position.x-2, _position.y+30 - 16, 50, "$" + cost);
        priceText.ID = 998;

        this.setSize(16, 16);
        this.offset.set(0, 16);
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.BOOT_BOUGHT, 1);
    }
}