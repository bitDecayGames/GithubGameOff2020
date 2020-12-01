package interactables;

import flixel.text.FlxText;
import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class HeartJar extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.HeartJar();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [10]);
        animation.play("inventory");

        name = "Heart Jar";
        cost = 25;

        priceText = new FlxText(_position.x-2, _position.y+30 - 16, 50, "$" + cost);
        priceText.ID = 998;

        this.setSize(16, 16);
        this.offset.set(0, 16);
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Bitlytics.Instance().Queue(Metrics.HEART_BOUGHT, 1);
        Player.state.baseStats.maxHealth = 6;
        Player.state.activeStats.maxHealth = 6;
        Player.state.activeStats.currentHealth = 6;
        _player.health = Player.state.baseStats.maxHealth;
        _player.refresh();
    }
}