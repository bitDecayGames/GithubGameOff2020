package entities.enemies;

import level.EnemyCache;
import js.html.TouchList;
import flixel.FlxG;
import flixel.math.FlxVector;
import behavior.tree.BTContext;
import behavior.tree.composite.Sequence;
import behavior.tree.composite.Selector;
import behavior.tree.composite.Parallel;
import behavior.tree.decorator.Repeater;
import behavior.leaf.PlayerAlive;
import behavior.leaf.util.Wait;
import behavior.leaf.util.Succeed;
import behavior.leaf.attack.AttackTarget;
import behavior.leaf.movement.ManhattanPath;
import behavior.leaf.movement.MoveBackAndForth;
import behavior.leaf.util.StartMovementAnimation;
import behavior.leaf.movement.StopMovement;
import behavior.leaf.position.InlineWithTarget;
import behavior.leaf.TargetPlayer;
import behavior.tree.BTree;
import behavior.NavBundle;
import flixel.util.FlxPath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import states.PlayState;
import entities.AcidShot;

class Snake extends Enemy {
    var behavior:BTree;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache) {
        super(_parentState, _player, position, cache);
        path = new FlxPath();

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
                                new AttackTarget()
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
        context.set("navBundle", new NavBundle(parentState.currentLevel, player));
        context.set("direction", FlxVector.get(0, -1).normalize());
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