package interactables;

import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class MatterConverter extends Interactable {

    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.MatterConverter();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [11]);
        animation.play("inventory");

        name = "Matter Converter";
        cost = 5;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        _player.baseStats.maxHealth += 2;
    }
}