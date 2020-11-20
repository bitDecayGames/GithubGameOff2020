package behavior.leaf.attack;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class AttackTarget extends LeafNode {

	public function new() {}

	override public function process(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);
        var target = cast(context.get("target"), FlxPoint);

        var diff = self.getPosition(FlxPoint.get()).subtractPoint(target);

        trace("the diff: ", diff);

        var attackAnimName = "attack_";

        if (Math.abs(diff.x) > Math.abs(diff.y)) {
            // left/right
            if (diff.x < 0) {
                attackAnimName += "right";
            } else {
                attackAnimName += "left";
            }
        } else {
            // up/down
            if (diff.y < 0) {
                attackAnimName += "down";
            } else {
                attackAnimName += "up";
            }
        }

        var attackAnimation = self.animation.getByName(attackAnimName);

        if (attackAnimation != null) {
            if (self.animation.curAnim.name != attackAnimName) {
                self.animation.play(attackAnimName);
                return RUNNING;
            } else {
                if (attackAnimation.finished) {
                    return SUCCESS;
                }
            }
        }

		return RUNNING;
	}
}