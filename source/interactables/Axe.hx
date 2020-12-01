package interactables;

import flixel.math.FlxPoint;
import entities.Player;

class Axe extends Interactable {
    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.Axe();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [2]);
        animation.play("inventory");

        name = "Pickaxe";
        cost = 1;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);

    }
}