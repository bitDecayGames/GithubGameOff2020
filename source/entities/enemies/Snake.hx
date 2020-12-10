package entities.enemies;

import entities.loots.GoldCoin;
import entities.loots.SilverCoin;
import entities.Enemy.LootTypeChance;
import entities.Enemy.LootChance;
import level.EnemyCache;
import js.html.TouchList;
import flixel.FlxG;
import flixel.math.FlxVector;
import com.bitdecay.behavior.tree.BTContext;
import com.bitdecay.behavior.tree.composite.Sequence;
import com.bitdecay.behavior.tree.composite.Selector;
import com.bitdecay.behavior.tree.composite.Parallel;
import com.bitdecay.behavior.tree.decorator.Repeater;
import behavior.leaf.PlayerAlive;
import com.bitdecay.behavior.tree.leaf.util.Wait;
import com.bitdecay.behavior.tree.leaf.util.Succeed;
import com.bitdecay.behavior.tree.leaf.attack.AttackTarget;
import com.bitdecay.behavior.tree.leaf.movement.ManhattanPath;
import behavior.leaf.MoveBackAndForth;
import com.bitdecay.behavior.tree.leaf.animation.StartMovementAnimation;
import com.bitdecay.behavior.tree.leaf.movement.StopMovement;
import com.bitdecay.behavior.tree.decorator.position.InlineWithTarget;
import behavior.leaf.TargetPlayer;
import com.bitdecay.behavior.tree.BTree;
import behavior.NavBundle;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;
import entities.AcidShot;

class Snake extends Enemy {
    var behavior:BTree;

	public function new(_parentState:PlayState, _player:Player, vertical:Bool, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache, FmodSFX.SnakeDeath);
        path = new FlxPath();

        enemyName = "Snake";
        lootChances = [
            new LootChance(1, 2),
        ];

        lootTypeChances = [
            new LootTypeChance(.5, SilverCoin),
            new LootTypeChance(.5, GoldCoin),
        ];

        baseStats.speed = 30;
        refresh();

        behavior = new BTree(
            new Repeater(
                new Selector([
                    new PlayerAlive(
                        new TargetPlayer(
                            new Sequence([
                                new InlineWithTarget(new Succeed()),
                                new StopMovement(),
                                new Wait(),
                                new AttackTarget(FmodSFX.SnakeVenom)
                            ])
                        )
                    ),
                    new Parallel([
                        new StartMovementAnimation(),
                        new MoveBackAndForth()
                    ])
                ])
            )
        );
        var context = new BTContext();
        context.set("self", this);
        context.set("speed", baseStats.speed);
        context.set("minWait", 0.25);
        context.set("navBundle", new NavBundle(parentState.currentLevel, player));

        var initialDirection = FlxVector.get(0, -1);
        if (!vertical) {
            initialDirection.rotate(FlxPoint.weak(), 90);
        }
        context.set("direction", initialDirection.normalize());
        behavior.init(context);


        super.loadGraphic(AssetPaths.snake__png, true, 16, 16);

        var animationSpeed:Int = 10;

        var famesPerRow = Std.int(this.frame.parent.width / width);

        animation.add("walk_up", [for (i in (famesPerRow * 2 + 1)...(famesPerRow * 3)) i], animationSpeed);
        animation.add("walk_down", [for (i in famesPerRow * 0 + 1...famesPerRow) i], animationSpeed);
        animation.add("walk_left", [for (i in (famesPerRow * 1 + 1)...(famesPerRow * 2)) i], animationSpeed);
        animation.add("walk_right", [for (i in (famesPerRow * 1 + 1)...(famesPerRow * 2)) i], animationSpeed);

        animation.add("stand_up", [famesPerRow * 2], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [famesPerRow * 1], animationSpeed);
        animation.add("stand_right", [famesPerRow * 1], animationSpeed);

        // 5 frames of the same frame each time
        animation.add("attack_up", [for (i in 0...5) famesPerRow * 3 + 2], animationSpeed, false);
        animation.add("attack_down", [for (i in 0...5) famesPerRow * 3], animationSpeed, false);
        animation.add("attack_left", [for (i in 0...5) famesPerRow * 3 + 1], animationSpeed, false, true); // why do I need to flip this here?
        animation.add("attack_right", [for (i in 0...5) famesPerRow * 3 + 1], animationSpeed, false);
        animation.add("dead", [44], animationSpeed);

        animation.play("stand_down");

        animation.callback = callback;

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
    }

    function callback(name:String, frameNumber:Int, frameIndex:Int) {
        // is it crappy to have the animation trigger the projectile?
        if (StringTools.startsWith(name, "attack_")) {
            if (frameNumber == 0) {
                if (StringTools.endsWith(name, "up")) {
                    parentState.addProjectile(new AcidShot(this.x, this.y, 270, 80));
                } else if (StringTools.endsWith(name, "down")) {
                    parentState.addProjectile(new AcidShot(this.x, this.y, 90, 80));
                } else if (StringTools.endsWith(name, "left")) {
                    parentState.addProjectile(new AcidShot(this.x, this.y, 180, 80));
                } else if (StringTools.endsWith(name, "right")) {
                    parentState.addProjectile(new AcidShot(this.x, this.y, 0, 80));
                }
            }
        }
    }

    override public function destroy() {
        kill();
    }

	override public function update(delta:Float):Void {
        super.update(delta);

        if (dead){
            return;
        }

        if (inKnockback) {
            path.cancel();
        }

		if (!inKnockback) {
            if (velocity.x > 0){
                facing = FlxObject.RIGHT;
            } else if (velocity.x < 0) {
                facing = FlxObject.LEFT;
            } else if (velocity.y < 0) {
                facing = FlxObject.UP;
            } else if (velocity.y > 0) {
                facing = FlxObject.DOWN;
            }

            behavior.process(delta);
        }
    }
}