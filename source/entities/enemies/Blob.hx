package entities.enemies;

import entities.Enemy.LootChance;
import level.EnemyCache;
import behavior.tree.composite.Parallel;
import behavior.leaf.util.StartMovementAnimation;
import flixel.FlxG;
import behavior.tree.BTContext;
import behavior.tree.composite.Sequence;
import behavior.tree.decorator.Repeater;
import behavior.leaf.util.IfNoTarget;
import behavior.leaf.util.Fail;
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

class Blob extends Enemy {
    var behavior:BTree;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache, FmodSFX.BlobDeath);
        path = new FlxPath();
        
        enemyName = "Blob";
        lootChances = [
            new LootChance(.3, 0),
            new LootChance(.5, 1),
            new LootChance(.2, 2),
        ];

        // frames persecond * move speed
        baseStats.speed = Std.int(1.5 * 16);
        refresh();

        behavior = new BTree(
            new Repeater(
                new Sequence([
                    new Wait(),
                    new IfNoTarget(new PickTargetInRange()),
                    new Parallel([
                        new Fail(new StartMovementAnimation()),
                        new ManhattanPath(),
                    ]),
                    new StartMovementAnimation()
                ])
            )
        );
        var context = new BTContext();
        context.set("self", this);
        context.set("speed", baseStats.speed);
        context.set("range", 16);
        context.set("cardinalLock", true);
        context.set("minWait", 1);
        // context.set("maxWait", 1);
        context.set("navBundle", new NavBundle(parentState.currentLevel, player));
        behavior.init(context);

        super.loadGraphic(AssetPaths.blob__png, true, 16, 16);

        var animationSpeed:Int = 4;

        animation.add("walk_up", [1,2,3], animationSpeed, false);
        animation.add("walk_right", [7,8,9], animationSpeed, false);
        animation.add("walk_down", [13,14,15], animationSpeed, false);
        animation.add("walk_left", [7,8,9], animationSpeed, false);
        animation.add("stand_up", [4,5,0], animationSpeed, false);
        animation.add("stand_right", [4,5,0], animationSpeed, false);
        animation.add("stand_down", [4,5,0], animationSpeed, false);
        animation.add("stand_left", [4,5,0], animationSpeed, false);

        animation.play("stand_down");

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
    }

    override public function destroy() {
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