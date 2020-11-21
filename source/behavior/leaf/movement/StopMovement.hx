package behavior.leaf.movement;

import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class StopMovement extends LeafNode {
	public function new() {}

	override public function doProcess(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);
		self.velocity.set();
		return SUCCESS;
	}
}