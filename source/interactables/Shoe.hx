package interactables;

import entities.Player;
import flixel.math.FlxPoint;
import upgrades.SpeedClog;

class Shoe extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = () -> return new upgrades.SpeedClog();

        loadGraphic(AssetPaths.speedClog__png, 16, 16);

        name = "SpeedClog";
        cost = 5;
    }
}