package entities;

import states.BaseState;
import entities.Stats.StatModifier;
import states.PlayState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class Entity extends FlxSprite {

    var parentState:BaseState;
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

    public function new(_parentState:BaseState) {
        super();

        parentState = _parentState;

        baseStats = new Stats();
        activeStats = new Stats();
        statModifiers = new Array<StatModifier>();
    }

    public function refresh() {
        baseStats.copyTo(activeStats);
        for (mod in statModifiers) {
            mod(activeStats);
        }
    }

    public function addModifier(mod:StatModifier) {
        statModifiers.push(mod);
        refresh();
    }
}