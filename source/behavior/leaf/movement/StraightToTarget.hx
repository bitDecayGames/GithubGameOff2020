package behavior.leaf.movement;

import flixel.FlxSprite;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;
import behavior.tree.BTContext;
import entities.Enemy;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.math.FlxPoint;

class StraightToTarget extends LeafNode {

	var started:Bool = false;

	public function new() {}

	public function generatePath(spr:FlxSprite, dest:FlxPoint, bundle:NavBundle):Array<FlxPoint> {
		var destinationTile = bundle.level.navigationLayer.getTileIndexByCoords(dest);
        var destinationTileCoords = bundle.level.navigationLayer.getTileCoordsByIndex(destinationTile, true);
        var points = bundle.level.navigationLayer.findPath(spr.getMidpoint(), destinationTileCoords, FlxTilemapDiagonalPolicy.NORMAL);
        return points;
	}

	override public function init(context:BTContext) {
		super.init(context);
		started = false;
	}

	override public function process(delta:Float):NodeStatus {
		var self = cast(context.get("self"), FlxSprite);
		var speed = cast(context.get("speed"), Float);

		if (!started) {
			started = true;
			if (context.get("target") == null) {
				return FAIL;
			}

			var points = generatePath(self, context.get("target"), context.get("navBundle"));
			if (points == null || points.length == 0) {
				return FAIL;
			}

			self.path.start(points, speed);
		} else {
			if (self.path.finished || self.path.nodes.length == 0) {
				started = false;
				return SUCCESS;
			}
		}

		return RUNNING;
	}
}