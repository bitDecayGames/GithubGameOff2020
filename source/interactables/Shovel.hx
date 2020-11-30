package interactables;

import com.bitdecay.analytics.Bitlytics;
import metrics.Metrics;
import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Shovel extends Interactable {

    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.Shovel();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [1]);
        animation.play("inventory");

        name = "Shovel";
        cost = 5;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.SHOVEL_BOUGHT, 1);

        _player.setCanAttack(true);
    }
}