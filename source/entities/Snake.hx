package entities;

import flixel.FlxG;
import flixel.math.FlxVector;
import behavior.tree.BTContext;
import behavior.tree.composite.Sequence;
import behavior.tree.composite.Selector;
import behavior.tree.decorator.Repeater;
import behavior.leaf.PlayerAlive;
import behavior.leaf.util.Wait;
import behavior.leaf.util.Succeed;
import behavior.leaf.movement.ManhattanPath;
import behavior.leaf.movement.MoveBackAndForth;
import behavior.leaf.position.InlineWithTarget;
import behavior.leaf.TargetPlayer;
import behavior.tree.BTree;
import behavior.NavBundle;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;

class Snake extends Enemy {
    var behavior:BTree;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint) {
        super(_parentState, _player, position);
        path = new FlxPath();
        speed = 30;

        behavior = new BTree(
            new Repeater(
                new Selector([
                    new PlayerAlive(
                        new TargetPlayer(
                            new Sequence([
                                new InlineWithTarget(new Succeed()),
                                new ManhattanPath()
                            ])
                        )
                    ),
                    new MoveBackAndForth()
                ])
            )
        );
        var context = new BTContext();
        context.set("self", this);
        context.set("speed", speed);
        context.set("navBundle", new NavBundle(parentState.currentLevel, player));
        context.set("direction", FlxVector.get(0, -1).normalize());
        behavior.init(context);


        super.loadGraphic(AssetPaths.snake__png, true, 16, 16);

        var animationSpeed:Int = 15;

        var famesPerRow = Std.int(this.frame.parent.width / width);

        animation.add("walk_up", [for (i in (famesPerRow * 2 + 1)...(famesPerRow * 3)) i], animationSpeed);
        animation.add("walk_down", [for (i in famesPerRow * 0 + 1...famesPerRow) i], animationSpeed);
        animation.add("walk_left", [for (i in (famesPerRow * 1 + 1)...(famesPerRow * 2)) i], animationSpeed);
        animation.add("walk_right", [for (i in (famesPerRow * 1 + 1)...(famesPerRow * 2)) i], animationSpeed);
        animation.add("stand_up", [famesPerRow * 2], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [famesPerRow * 1], animationSpeed);
        animation.add("stand_right", [famesPerRow * 1], animationSpeed);

        animation.play("stand_down");

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
            behavior.process(delta);

            if (velocity.x > 0){
                facing = FlxObject.RIGHT;
            } else if (velocity.x < 0) {
                facing = FlxObject.LEFT;
            } else if (velocity.y < 0) {
                facing = FlxObject.UP;
            } else if (velocity.y > 0) {
                facing = FlxObject.DOWN;
            }

            playAnimation(facing, velocity);
        }
    }

	function playAnimation(_facing:Int, _directionVector:FlxPoint){
        FlxG.watch.addQuick("given velocity: ", _directionVector);
        FlxG.watch.addQuick("given facing: ", _facing);
        if (_directionVector == null || (_directionVector.x == 0 && _directionVector.y == 0)) {
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