package behavior.leaf.attack;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class AttackTarget extends LeafNode {

    var attackSound:String;

	public function new(?_attackSound:String = null) {
        attackSound = _attackSound;
    }

	override public function doProcess(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);
        var target = cast(context.get("target"), FlxPoint);

        var diff = self.getPosition(FlxPoint.get()).subtractPoint(target);

        var attackAnimPrefix = "attack_";
        var attackAnimName = "attack_";

        if (Math.abs(diff.x) > Math.abs(diff.y)) {
            // left/right
            if (diff.x < 0) {
                attackAnimName = attackAnimPrefix + "right";
            } else {
                attackAnimName = attackAnimPrefix + "left";
            }
        } else {
            // up/down
            if (diff.y < 0) {
                attackAnimName = attackAnimPrefix + "down";
            } else {
                attackAnimName = attackAnimPrefix + "up";
            }
        }

        var attackAnimation = self.animation.getByName(attackAnimName);

        if (attackAnimation != null) {
            if (!StringTools.contains(self.animation.curAnim.name, attackAnimPrefix)) {
                // Only start new animation if we aren't already in some attack animation
                if (attackSound != null) {
                    FmodManager.PlaySoundOneShot(attackSound);
                }
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