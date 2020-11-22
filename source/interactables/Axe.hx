package interactables;

import flixel.math.FlxPoint;
import entities.Player;

class Axe extends Interactable {
    public function new(_position:FlxPoint) {
        super(_position);
        super.loadGraphic(AssetPaths.axe__png, true, 16, 16);

        name = "Axe";
        cost = 10;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
    }
}