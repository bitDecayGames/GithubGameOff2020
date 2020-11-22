package interactables;

import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Shovel extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = new upgrades.Shovel();

        this.frame = containedUpgrade.frame;

        name = "Shovel";
        cost = 5;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        _player.setCanAttack(true);
    }
}