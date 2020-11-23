package entities;

import interactables.Interactable;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class RopeUp extends Interactable {

    var timeActive:Float;

    public function new(_position:FlxPoint) {
        super(_position);
        super.makeGraphic(16, 16, FlxColor.TRANSPARENT);

        name = "RopeUp";
        cost = 0;
    }
}