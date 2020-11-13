package entities;

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

class Player extends Entity {

    var controls:Actions;
    var stepFXPlayed:Bool = false;
    var movementRatio = new FlxPoint(1, 0.8);

    var playerHitboxOffsetX = 4;
    var playerHitboxOffsetY = 8;

    public var invincibilityTimeLeft:Float = 0;

    public var shovel:FlxSprite;

	public function new(_parentState:PlayState, _spawnPosition:FlxPoint) {
        super();
        controls = new Actions();
        health = 5;
        size = new FlxPoint(16, 32);
        speed = 75;
        direction = 0;
        attacking = false;
        parentState = _parentState;
        setPosition(_spawnPosition.x, _spawnPosition.y);

        super.loadGraphic(AssetPaths.Player__png, true, 16, 32);

        // Update hitbox to be smaller than sprite
        setSize(8, 16);
        offset.set(playerHitboxOffsetX, playerHitboxOffsetY);

        var animationSpeed:Int = 8;

        animation.add("walk_up", [19,20,21,22,23,24,25,26], animationSpeed);
        animation.add("walk_right", [10,11,12,13,14,15,16,17], animationSpeed);
        animation.add("walk_down", [1,2,3,4,5,6,7,8], animationSpeed);
        animation.add("walk_left", [10,11,12,13,14,15,16,17], animationSpeed);
        animation.add("stand_up", [18], animationSpeed);
        animation.add("stand_right", [9], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [9], animationSpeed);

        animation.play("stand_down");

        animation.callback = animCallback;

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
    }

    public function animCallback(name:String, frameNumber:Int, frameIndex:Int):Void {
		if (!stepFXPlayed && StringTools.contains(name, "walk_") && frameNumber == 3 || frameNumber == 7) {
			FmodManager.PlaySoundOneShot(FmodSFX.FootstepRock);
            stepFXPlayed = true;
		} else {
            // reset this once a different frame happens
            stepFXPlayed = false;
        }
	}

	override public function update(delta:Float):Void {
        super.update(delta);
        if (invincibilityTimeLeft > 0){
            invincibilityTimeLeft -= delta;
        }

        var potentialDirection:FlxPoint = new FlxPoint(0, 0);
		potentialDirection = readDirectionInput();
        facing = determineFacing(potentialDirection);

        if (inKnockback){
            setPosition(x + knockbackDirection.x*delta*knockbackSpeed, y + knockbackDirection.y*delta*knockbackSpeed*-1);
            knockbackDuration -= delta;
            if (knockbackDuration <= 0) {
                inKnockback = false;
                if (health <= 0) {
                    FmodFlxUtilities.TransitionToState(new PlayState());
                }
            }
            playDamageAnimation(facing);
        } else {
            if (controls.attack.check() && !attacking) {

                attacking = true;
                attack(facing);
                Timer.delay(() -> {
                    attacking = false;
                }, 200);
            }

            var directionVector:FlxPoint = null;
            if (!attacking){
                directionVector = MathHelpers.NormalizeVector(potentialDirection);
                directionVector.scale(delta*speed);
                // y needs to be flipped to move character in the right direction
                setPosition(x + directionVector.x, y + directionVector.y);
            }
            playAnimation(facing, directionVector);
        }
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
                    animation.play("walk_right", animation.curAnim.curFrame);
                case FlxObject.DOWN:
                    animation.play("walk_down", animation.curAnim.curFrame);
                case FlxObject.LEFT:
                    animation.play("walk_left", animation.curAnim.curFrame);
                case FlxObject.UP:
                    animation.play("walk_up", animation.curAnim.curFrame);
            }
        }
    }

    function playDamageAnimation(_facing:Int){
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
    }

    public function applyDamage(_damage:Int) {
        health -= _damage;
    }

    public function setKnockback(_knockbackDirection:FlxPoint, _knockbackSpeed:Float, _knockbackDuration:Float) {
        inKnockback = true;
        knockbackDirection = _knockbackDirection;
        knockbackSpeed = _knockbackSpeed;
        knockbackDuration = _knockbackDuration;

        FlxFlicker.flicker(this, knockbackDuration*4);
        invincibilityTimeLeft = knockbackDuration*4;
    }

    function attack(facing:Int) {

        if (shovel != null){
            shovel.destroy();
        }

        FmodManager.PlaySoundOneShot(FmodSFX.ShovelSwing);

        var attackLocation:FlxPoint;
        var hitboxSize = new FlxPoint(20, 20);

        switch facing {
            case FlxObject.RIGHT:
                attackLocation = new FlxPoint(x+size.x/2, y+(size.y/2)-(hitboxSize.y/2)-playerHitboxOffsetY);
            case FlxObject.DOWN:
                attackLocation = new FlxPoint(x+(size.x/2)-(hitboxSize.x/2)-playerHitboxOffsetX, y+size.y/2);
            case FlxObject.LEFT:
                attackLocation = new FlxPoint(x-hitboxSize.x, y+(size.y/2)-(hitboxSize.y/2)-playerHitboxOffsetY);
            case FlxObject.UP:
                attackLocation = new FlxPoint(x+(size.x/2)-(hitboxSize.x/2)-playerHitboxOffsetX, y-hitboxSize.y);
            default:
                attackLocation = new FlxPoint(x, y);
        }
        var hitbox = new Hitbox(.2, attackLocation, hitboxSize);
        parentState.addHitbox(hitbox);
        spawnShovel(hitbox.getMidpoint(), facing);
    }

    function spawnShovel(position:FlxPoint, facing:Int) {
        shovel = new FlxSprite();
        parentState.add(shovel);
        shovel.loadGraphic(AssetPaths.Player__png, true, 16, 32);
        shovel.animation.add("swing", [27,28,29,30,31,32,33,34,35], 30);
        shovel.animation.play("swing");
        shovel.setMidpoint(position.x, position.y);
        shovel.animation.callback = shovelAnimCallback;

        switch facing {
            case FlxObject.RIGHT:
                shovel.angle = 0;
            case FlxObject.DOWN:
                shovel.angle = 90;
            case FlxObject.LEFT:
                shovel.angle = 180;
            case FlxObject.UP:
                shovel.angle = 270;
            default:
                shovel.angle = 225;
        }
    }

    public function shovelAnimCallback(name:String, frameNumber:Int, frameIndex:Int):Void {
        if (name == "swing") {
            if (frameNumber == 8) {
                shovel.destroy();
            }
        }
	}

    function readDirectionInput():FlxPoint {

        var _potentialDirection = new FlxPoint(0, 0);

        if (controls.up.check()) {
            _potentialDirection.add(0, -1);
        }

		if (controls.down.check()) {
            _potentialDirection.add(0, 1);
        }

		if (controls.left.check()) {
            _potentialDirection.add(-1, 0);
        }

		if (controls.right.check()) {
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
            return FlxObject.UP;
        } else if (vector.y > 0) {
            return FlxObject.DOWN;
        }

        return facing;
    }
}
