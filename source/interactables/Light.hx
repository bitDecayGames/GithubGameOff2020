package interactables;

import flixel.text.FlxText;
import com.bitdecay.analytics.Bitlytics;
import metrics.Metrics;
import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Light extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.Light();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [8]);
        animation.play("inventory");

        name = "LED Bulb";
        cost = 30;

        priceText = new FlxText(_position.x-2, _position.y+30 - 16, 50, "$" + cost);
        priceText.ID = 998;

        this.setSize(16, 16);
        this.offset.set(0, 16);
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.BULB_BOUGHT, 1);
        Statics.MaxLightRadius += 25;
        Statics.lightDrainRate = .75;
    }
}