package interactables;

import com.bitdecay.analytics.Bitlytics;
import metrics.Metrics;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import entities.Player;

class Axe extends Interactable {
    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.Axe();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [2]);
        animation.play("inventory");

        name = "Pickaxe";
        cost = 100;

        priceText = new FlxText(_position.x-2, _position.y+30 - 16, 50, "$" + cost);
        priceText.ID = 998;

        this.setSize(16, 16);
        this.offset.set(0, 16);
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.AXE_BOUGHT, 1);
    }
}