package interactables;

import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Shovel extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.Shovel();

        loadGraphic(AssetPaths.shovel__png, true, 16, 16);

        animation.add("inventory", [0]);
        animation.play("inventory");

        name = "Shovel";
        cost = 5;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        _player.setCanAttack(true);
    }
}