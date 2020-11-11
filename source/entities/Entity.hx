package entities;

import states.PlayState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class Entity extends FlxSprite{

    var parentState:PlayState;
    var size:FlxPoint;
    var speed:Int;
    var direction:Int;
    var attacking:Bool;
    var healthPoints:Int;

    // Knockback
    public var inKnockback:Bool;
    var knockbackDirection:FlxPoint;
    var knockbackSpeed:Float;
    var knockbackDuration:Float;
}