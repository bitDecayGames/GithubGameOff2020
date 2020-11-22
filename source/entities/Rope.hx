package entities;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Rope extends FlxSprite {

    var timeActive:Float;

    public function new(_position:FlxPoint, _size:FlxPoint) {
        super(_position.x, _position.y);
    }
}