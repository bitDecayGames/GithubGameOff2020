package entities;

import upgrades.Upgrade;
import states.BaseState;
import entities.Stats.StatModifier;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.effects.FlxFlicker;
import actions.Actions;
import states.PlayState;
import haxe.Timer;
import flixel.util.FlxColor;
import haxefmod.FmodManager;
import helpers.MathHelpers;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
using extensions.FlxObjectExt;

class Shopkeep extends Entity {


	public function new(_spawnPosition:FlxPoint) {
        super();
        setPosition(_spawnPosition.x, _spawnPosition.y);
        super.loadGraphic(AssetPaths.shopkeep__png, true, 16, 32);

        var animationSpeed:Int = 8;

        animation.add("walk_down", [1,2,3,4,5,6,7,8], animationSpeed);
        animation.add("walk_up", [10,11,12,13,14,15,16,17], animationSpeed);

        animation.add("stand_down", [0], animationSpeed);

        animation.play("stand_down");

        animation.callback = animCallback;
        animation.finishCallback = animationOnFinishCallback;
    }

    public function animCallback(name:String, frameNumber:Int, frameIndex:Int):Void {

    }

    public function animationOnFinishCallback(name:String) {

    }

	override public function update(delta:Float):Void {
        super.update(delta);
    }
}
