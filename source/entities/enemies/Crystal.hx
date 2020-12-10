package entities.enemies;

import flixel.util.FlxColor;
import entities.loots.GoldCoin;
import entities.Enemy.LootTypeChance;
import entities.Enemy.LootChance;
import level.EnemyCache;
import com.bitdecay.behavior.tree.composite.Parallel;
import com.bitdecay.behavior.tree.leaf.animation.StartMovementAnimation;
import flixel.FlxG;
import com.bitdecay.behavior.tree.BTContext;
import com.bitdecay.behavior.tree.composite.Sequence;
import com.bitdecay.behavior.tree.decorator.Repeater;
import com.bitdecay.behavior.tree.decorator.util.IfNoTarget;
import com.bitdecay.behavior.tree.decorator.basic.Fail;
import behavior.leaf.PlayerAlive;
import com.bitdecay.behavior.tree.leaf.util.Wait;
import behavior.leaf.SetAnimationToHealth;
import behavior.leaf.PickTargetInRange;
import com.bitdecay.behavior.tree.leaf.movement.ManhattanPath;
import com.bitdecay.behavior.tree.leaf.movement.StraightToTarget;
import behavior.leaf.TargetPlayer;
import com.bitdecay.behavior.tree.BTree;
import behavior.NavBundle;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;

class Crystal extends Enemy {
    var behavior:BTree;


	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache);
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

        if (health <= 0 && !dead) {
            Statics.CurrentLightRadius = 10000000;
            FlxG.camera.flash(FlxColor.WHITE, 3);
            FmodManager.StopSoundImmediately("Crystal");
            FmodManager.PlaySoundOneShot(FmodSFX.CrystalBreak);
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