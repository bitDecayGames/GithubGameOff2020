package interactables;

import upgrades.Upgrade;
import flixel.math.FlxPoint;
import entities.Player;

class Light extends Interactable {

    public function new(_position:FlxPoint) {
        // going from a position for 16x16, so we need to adjust up one tile to line up
        _position.y -= 16;
        super(_position);

        containedUpgrade = () -> return new upgrades.Light();

        loadGraphic(AssetPaths.interactables__png, true, 16, 32);

        animation.add("inventory", [8]);
        animation.play("inventory");

        name = "LED Bulb";
        cost = 50;
    }

    override public function onInteract(_player:Player) {
        super.onInteract(_player);
        Statics.MaxLightRadius += 25;
        Statics.lightDrainRate = .75;
    }
}