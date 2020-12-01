package interactables;

import flixel.text.FlxText;
import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class HeartJar extends Interactable {

    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.HeartJar();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [10]);
        animation.play("inventory");

        name = "Heart Jar";
        cost = 25;

        priceText = new FlxText(_position.x-2, _position.y+30, 50, "$" + cost);
        priceText.ID = 998;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.HEART_BOUGHT, 1);
        Player.state.baseStats.maxHealth += 2;
        Player.state.activeStats.maxHealth += 2;
        Player.state.activeStats.currentHealth += 2;
        _player.health = Player.state.baseStats.maxHealth;
        _player.refresh();
    }
}