package interactables;

import flixel.math.FlxPoint;
import entities.Player;

class Shovel extends Interactable {
    public function new(_position:FlxPoint) {
        super(_position);
        super.loadGraphic(AssetPaths.shovel__png, true, 16, 16);

        name = "Shovel";
        cost = 5;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        _player.setCanAttack(true);
    }
}