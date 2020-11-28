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

        loadGraphic(AssetPaths.interactables__png, true, 16, 16);

        animation.add("inventory", [6]);
        animation.play("inventory");

        name = "RopeUp";
        cost = 0;
    }
}