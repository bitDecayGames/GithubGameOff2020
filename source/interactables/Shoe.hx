package interactables;

import entities.Player;
import flixel.math.FlxPoint;
import upgrades.SpeedClog;

class Shoe extends Interactable {

    public function new(_position:FlxPoint) {
        super(_position);

        containedUpgrade = new upgrades.SpeedClog();

        this.frame = containedUpgrade.frame;

        name = "SpeedClog";
        cost = 5;
    }
}