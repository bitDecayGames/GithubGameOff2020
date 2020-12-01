package entities.enemies;

import entities.loots.GoldCoin;
import entities.Enemy.LootTypeChance;
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
import behavior.leaf.util.SetAnimationToHealth;
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

class Crystal extends Enemy {
    var behavior:BTree;


	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache, FmodSFX.BlobDeath);
        path = new FlxPath();

        enemyName = "Crystal";
        lootChances = [
            new LootChance(1, 0),
        ];

        health = 5;
        refresh();

        behavior = new BTree(
            new Repeater(
                new SetAnimationToHealth()
            )
        );
        var context = new BTContext();
        context.set("self", this);
        behavior.init(context);

        super.loadGraphic(AssetPaths.crystal__png, true, 32, 48);

        var animationSpeed:Int = 4;

        animation.add("5", [0], animationSpeed, false);
        animation.add("4", [1], animationSpeed, false);
        animation.add("3", [2], animationSpeed, false);
        animation.add("2", [3], animationSpeed, false);
        animation.add("1", [4], animationSpeed, false);
        animation.add("0", [5], animationSpeed, false);
        animation.add("dead", [5], animationSpeed, false);

        animation.play("5");
    }

    override public function destroy() {
        kill();
    }

	override public function update(delta:Float):Void {
        super.update(delta);

        if (health <= 0) {
            dead = true;
        }

        if (dead){
            return;
        }

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