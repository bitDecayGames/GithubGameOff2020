package behavior.leaf;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import com.bitdecay.behavior.tree.NodeStatus;
import com.bitdecay.behavior.tree.leaf.LeafNode;

class SetAnimationToHealth extends LeafNode {

	public function new() {}

	override public function doProcess(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);

        self.animation.play("" + self.health);

        return SUCCESS;
    }
}