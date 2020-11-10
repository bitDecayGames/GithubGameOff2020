package entities;

import states.PlayState;
import haxe.Timer;
import flixel.util.FlxColor;
import haxefmod.FmodManager;
import helpers.MathHelpers;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends Entity {

	public function new(_parentState:PlayState) {
        super();
        size = new FlxPoint(16, 32);
        speed = 75;
        direction = 0;
        attacking = false;
        parentState = _parentState;
        setPosition(0, 0);

        super.loadGraphic(AssetPaths.player__png, true, 16, 32);

        var animationSpeed:Int = 8;

        animation.add("walk_up", [19,20,21,22,23,24,25,26], animationSpeed);
        animation.add("walk_right", [10,11,12,13,14,15,16,17], animationSpeed);
        animation.add("walk_down", [1,2,3,4,5,6,7,8], animationSpeed);
        animation.add("walk_left", [10,11,12,13,14,15,16,17], animationSpeed);
        animation.add("stand_up", [18], animationSpeed);
        animation.add("stand_right", [9], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [9], animationSpeed);

        animation.callback = animCallback;

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
    }
    
    public function animCallback(name:String, frameNumber:Int, frameIndex:Int):Void {
		if (StringTools.contains(name, "walk_") && frameNumber == 3 || frameNumber == 7) {
			FmodManager.PlaySoundOneShot(FmodSFX.FootstepRock);
		}
	}

	override public function update(delta:Float):Void {
		super.update(delta);
        var potentialDirection:FlxPoint = new FlxPoint(0, 0);
		potentialDirection = readDirectionInput();
        facing = determineFacing(potentialDirection);

		if (FlxG.keys.justPressed.Z && !attacking) {

            attacking = true;
            attack(facing);
            Timer.delay(() -> {
                attacking = false;
            }, 200);
        }

        var directionVector:FlxPoint = null;
        if (!attacking){
            directionVector = MathHelpers.NormalizeVector(potentialDirection);
            // y needs to be flipped to move character in the right direction
            setPosition(x + directionVector.x*delta*speed, y + directionVector.y*delta*speed*-1);
        }
        playAnimation(facing, directionVector);
    }

    function playAnimation(_facing:Int, _directionVector:FlxPoint){
        if (_directionVector == null || _directionVector.x == 0 && _directionVector.y == 0){
            switch _facing {
                case FlxObject.RIGHT:
                    animation.play("stand_right");
                case FlxObject.DOWN:
                    animation.play("stand_down");
                case FlxObject.LEFT:
                    animation.play("stand_left");
                case FlxObject.UP:
                    animation.play("stand_up");
            }
        } else {
            switch _facing {
                case FlxObject.RIGHT:
                    animation.play("walk_right");
                case FlxObject.DOWN:
                    animation.play("walk_down");
                case FlxObject.LEFT:
                    animation.play("walk_left");
                case FlxObject.UP:
                    animation.play("walk_up");
            }
        }
    }

    function attack(facing:Int) {

        FmodManager.PlaySoundOneShot(FmodSFX.ShovelSwing);

        var attackLocation:FlxPoint;
        var hitboxSize = new FlxPoint(20, 20);

        switch facing {
            case FlxObject.RIGHT:
                attackLocation = new FlxPoint(x+size.x, y+(size.y/2)-(hitboxSize.y/2));
            case FlxObject.DOWN:
                attackLocation = new FlxPoint(x+(size.x/2)-hitboxSize.x/2, y+size.y);
            case FlxObject.LEFT:
                attackLocation = new FlxPoint(x-hitboxSize.x, y+(size.y/2)-(hitboxSize.y/2));
            case FlxObject.UP:
                attackLocation = new FlxPoint(x+(size.x/2)-(hitboxSize.x/2), y-hitboxSize.y);
            default:
                attackLocation = new FlxPoint(x, y);
        }
        var hitbox = new Hitbox(.2, attackLocation, hitboxSize);
        parentState.addHitbox(hitbox);
    }

    function readDirectionInput():FlxPoint {

        var _potentialDirection = new FlxPoint(0, 0);

        if (FlxG.keys.pressed.UP) {
            _potentialDirection.add(0, 1);
        } 
        
		if (FlxG.keys.pressed.DOWN) {
            _potentialDirection.add(0, -1);
        } 
        
		if (FlxG.keys.pressed.LEFT) {
            _potentialDirection.add(-1, 0);
        } 
        
		if (FlxG.keys.pressed.RIGHT) {
            _potentialDirection.add(1, 0);
        } 

        return _potentialDirection;
    }

    function determineFacing(vector:FlxPoint):Int {
        if (vector.x > 0 && vector.y > 0) {
            if (facing == FlxObject.UP || facing == FlxObject.RIGHT){
                return facing;
            }
        } else if (vector.x > 0 && vector.y < 0) {
            if (facing == FlxObject.DOWN || facing == FlxObject.RIGHT){
                return facing;
            }
        } else if (vector.x < 0 && vector.y < 0) {
            if (facing == FlxObject.DOWN || facing == FlxObject.LEFT){
                return facing;
            }
        } else if (vector.x < 0 && vector.y > 0) {
            if (facing == FlxObject.UP || facing == FlxObject.LEFT){
                return facing;
            }
        }

        if (vector.x > 0){
            return FlxObject.RIGHT;
        } else if (vector.x < 0) {
            return FlxObject.LEFT;
        } else if (vector.y < 0) {
            return FlxObject.DOWN;
        } else if (vector.y > 0) {
            return FlxObject.UP;
        }

        return facing;
    }
}
