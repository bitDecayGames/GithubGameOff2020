package entities;

import entities.Stats.StatModifier;
import states.PlayState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class Entity extends FlxSprite {

    var parentState:PlayState;
    var size:FlxPoint;
    var direction:Int;
    var attacking:Bool;

    // Knockback
    public var inKnockback:Bool;
    var knockbackDirection:FlxPoint;
    var knockbackSpeed:Float;
    var knockbackDuration:Float;

    public var baseStats:Stats;
    public var statModifiers:Array<StatModifier>;
    public var activeStats:Stats;

    public function new() {
        super();

        baseStats = new Stats();
        activeStats = new Stats();
        statModifiers = new Array<StatModifier>();
    }

    public function refresh() {
        baseStats.copyTo(activeStats);
    }

    public function addModifier(mod:StatModifier) {
        refresh();
        statModifiers.push(mod);
        for (mod in statModifiers) {
            mod(activeStats);
        }
    }
}