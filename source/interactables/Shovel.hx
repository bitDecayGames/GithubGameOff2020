package interactables;

import flixel.text.FlxText;
import com.bitdecay.analytics.Bitlytics;
import metrics.Metrics;
import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Shovel extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.Shovel();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [1]);
        animation.play("inventory");

        name = "Shovel";
        cost = 5;

        priceText = new FlxText(_position.x-2, _position.y+30 - 16, 50, "$" + cost);
        priceText.ID = 998;

        this.setSize(16, 16);
        this.offset.set(0, 16);
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.SHOVEL_BOUGHT, 1);

        _player.setCanAttack(true);
    }
}