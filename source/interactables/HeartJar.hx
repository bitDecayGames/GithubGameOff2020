package interactables;

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
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Player.state.baseStats.maxHealth += 2;
        Player.state.activeStats.maxHealth += 2;
        Player.state.activeStats.currentHealth += 2;
        _player.refresh();
    }
}