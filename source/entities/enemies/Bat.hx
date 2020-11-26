package entities.enemies;

import level.EnemyCache;
import behavior.leaf.util.Fail;
import behavior.tree.composite.Parallel;
import behavior.leaf.util.StartMovementAnimation;
import flixel.FlxG;
import behavior.tree.BTContext;
import behavior.tree.composite.Sequence;
import behavior.tree.decorator.Repeater;
import behavior.leaf.PlayerAlive;
import behavior.leaf.util.Wait;
import behavior.leaf.util.PickTargetInRange;
import behavior.leaf.movement.ManhattanPath;
import behavior.leaf.movement.StraightToTarget;
import behavior.leaf.TargetPlayer;
import behavior.tree.BTree;
import behavior.NavBundle;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;

class Bat extends Enemy {
    var behavior:BTree;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache);
        path = new FlxPath();

        baseStats.speed = 15;
        refresh();

        behavior = new BTree(
            new Repeater(
                new Sequence([
                    new Wait(),
                    new PickTargetInRange(),
                    new Parallel([
                        new Fail(new StartMovementAnimation()),
                        new StraightToTarget(),
                    ]),
                    new StartMovementAnimation(),
                ])
            )
        );
        var context = new BTContext();
        context.set("self", this);
        context.set("speed", baseStats.speed);
        context.set("range", 100);
        context.set("minWait", 1);
        context.set("maxWait", 2);
        context.set("navBundle", new NavBundle(parentState.currentLevel, player));
        behavior.init(context);


        super.loadGraphic(AssetPaths.bat__png, true, 16, 16);

        var animationSpeed:Int = 15;

        animation.add("walk_up", [1,2,3,4], animationSpeed);
        animation.add("walk_right", [1,2,3,4], animationSpeed);
        animation.add("walk_down", [1,2,3,4], animationSpeed);
        animation.add("walk_left", [1,2,3,4], animationSpeed);
        animation.add("stand_up", [0], animationSpeed);
        animation.add("stand_right", [0], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [0], animationSpeed);

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
        }
    }
}