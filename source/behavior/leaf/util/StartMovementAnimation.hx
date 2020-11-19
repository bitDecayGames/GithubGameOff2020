package behavior.leaf.util;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class StartMovementAnimation extends LeafNode {

	public function new() {}

	override public function process(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);

        playAnimation(self);

        return SUCCESS;
    }

    function playAnimation(self:FlxSprite){
        if (self.velocity == null || (self.velocity.x == 0 && self.velocity.y == 0)) {
            switch self.facing {
                case FlxObject.RIGHT:
                    trace("playing stand_right");
                    self.animation.play("stand_right");
                case FlxObject.DOWN:
                    trace("playing stand_down");
                    self.animation.play("stand_down");
                case FlxObject.LEFT:
                    trace("playing stand_left");
                    self.animation.play("stand_left");
                case FlxObject.UP:
                    trace("playing stand_up");
                    self.animation.play("stand_up");
            }
        } else {
            switch self.facing {
                case FlxObject.RIGHT:
                    trace("playing walk_right");
                    self.animation.play("walk_right", self.animation.curAnim.curFrame);
                case FlxObject.DOWN:
                    trace("playing walk_down");
                    self.animation.play("walk_down", self.animation.curAnim.curFrame);
                case FlxObject.LEFT:
                    trace("playing walk_left");
                    self.animation.play("walk_left", self.animation.curAnim.curFrame);
                case FlxObject.UP:
                    trace("playing walk_up");
                    self.animation.play("walk_up", self.animation.curAnim.curFrame);
            }
        }
    }
}