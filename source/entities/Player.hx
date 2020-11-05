package entities;

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

class Player extends FlxSprite {

    var parentState:FlxState;

    var playerSize:FlxPoint = new FlxPoint(40, 40);
    
    var playerFacingDirection:FlxText;

    var speed = 160;
    var direction = 0;

    var attacking = false;

	public function new(_parentState:FlxState) {
        super();
        parentState = _parentState;
        makeGraphic(Std.int(playerSize.x), Std.int(playerSize.y), FlxColor.WHITE);
        setPosition(0, 0);

        playerFacingDirection = new FlxText();
        playerFacingDirection.color = FlxColor.RED;

        Timer.delay(() -> {
            parentState.insert(parentState.length, playerFacingDirection);
        }, 1000);
	}

	override public function update(delta:Float):Void {
		super.update(delta);
        var potentialDirection:FlxPoint = new FlxPoint(0, 0);
		potentialDirection = readDirectionInput();
        facing = determineFacing(potentialDirection);

		if (FlxG.keys.justPressed.Z && !attacking) {
            attacking = true;
			trace('Attacking');
            Timer.delay(() -> {
                attacking = false;
            }, 1000);
        }

        updateFacingText(facing);
        playerFacingDirection.setPosition(this.x, this.y);

        var directionVector = MathHelpers.NormalizeVector(potentialDirection);
        // y needs to be flipped to move character in the right direction
        setPosition(x + directionVector.x*delta*speed, y + directionVector.y*delta*speed*-1);
    }

    function updateFacingText(facing:Int) {
        switch facing {
            case FlxObject.RIGHT:
                playerFacingDirection.text = "Right";
            case FlxObject.DOWN:
                playerFacingDirection.text = "Down";
            case FlxObject.LEFT:
                playerFacingDirection.text = "Left";
            case FlxObject.UP:
                playerFacingDirection.text = "Up";
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
