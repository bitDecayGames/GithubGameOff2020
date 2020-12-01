package behavior.leaf.util;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class SetAnimationToHealth extends LeafNode {

	public function new() {}

	override public function doProcess(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);

        self.animation.play("" + self.health);

        return SUCCESS;
    }
}