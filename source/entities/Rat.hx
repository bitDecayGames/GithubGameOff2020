package entities;

import behavior.NavBundle;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;
import behavior.movement.MovementBehavior;
import behavior.movement.ManhattanPath;
import behavior.aggression.AggressionBehavior;
import behavior.aggression.FinishPath;

class Rat extends Enemy {

    var movement:MovementBehavior;
    var aggro:AggressionBehavior;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint) {
        super(_parentState, _player, position);
        path = new FlxPath();
        movement = new ManhattanPath(_player);
        aggro = new FinishPath();

        speed = 30;

        super.loadGraphic(AssetPaths.rat__png, true, 16, 16);

        var animationSpeed:Int = 5;

        animation.add("walk_up", [7, 8], animationSpeed);
        animation.add("walk_right", [4, 5], animationSpeed);
        animation.add("walk_down", [1, 2], animationSpeed);
        animation.add("walk_left", [4, 5], animationSpeed);
        animation.add("stand_up", [6], animationSpeed);
        animation.add("stand_right", [3], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [3], animationSpeed);

        animation.play("stand_down");

        // animation.callback = animCallback;

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
    }

    override public function destroy() {
        FmodManager.PlaySoundOneShot(FmodSFX.RatDeath);
        kill();
    }

	override public function update(delta:Float):Void {
		super.update(delta);

        if (inKnockback) {
            path.cancel();
        }

		if (!inKnockback) {
            // this nav bundle should get created somewhere else
            var bundle = new NavBundle(parentState.currentLevel, player);
            if (path.finished || path.nodes.length == 0) {
                path.start(movement.generatePath(this, bundle), speed);
            }

            if (aggro.trigger(this, bundle)) {
                // TODO: enter ATTACK STATE
            }

			playAnimation(facing, directionVector);
        }
    }

    private function generateNewPath() {
        var playerTile = level.navigationLayer.getTileIndexByCoords(player.getMidpoint());
        var playerTileCoords = level.navigationLayer.getTileCoordsByIndex(playerTile, true);
        var points = level.navigationLayer.findPath(getMidpoint(), playerTileCoords, FlxTilemapDiagonalPolicy.NONE);
        if (points != null) {
            path.start(points, speed);
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
}