package entities;

import states.PlayState;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.tweens.FlxTween;
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
        size = new FlxPoint(40, 40);
        speed = 160;
        direction = 0;
        attacking = false;
        parentState = _parentState;
        makeGraphic(Std.int(size.x), Std.int(size.y), FlxColor.WHITE);
        setPosition(0, 0);

        facingDirection = new FlxText();
        facingDirection.color = FlxColor.RED;

        Timer.delay(() -> {
            parentState.insert(parentState.length, facingDirection);
        }, 1000);
	}

	override public function update(delta:Float):Void {
		super.update(delta);
        var potentialDirection:FlxPoint = new FlxPoint(0, 0);
		potentialDirection = readDirectionInput();
        facing = determineFacing(potentialDirection);

		if (FlxG.keys.justPressed.Z && !attacking) {

            attacking = true;
            attack(facing);
			trace('Attacking');
            Timer.delay(() -> {
                attacking = false;
            }, 200);
        }

        var directionVector = MathHelpers.NormalizeVector(potentialDirection);
        if (!attacking){
            updateFacingText(facing);
            facingDirection.setPosition(this.x, this.y);
            // y needs to be flipped to move character in the right direction
            setPosition(x + directionVector.x*delta*speed, y + directionVector.y*delta*speed*-1);
        }
    }

    function attack(facing:Int) {

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

    function updateFacingText(facing:Int) {
        switch facing {
            case FlxObject.RIGHT:
                facingDirection.text = "Right";
            case FlxObject.DOWN:
                facingDirection.text = "Down";
            case FlxObject.LEFT:
                facingDirection.text = "Left";
            case FlxObject.UP:
                facingDirection.text = "Up";
        }
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
