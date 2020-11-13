package behavior.leaf.movement;

import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;
import behavior.tree.BTContext;
import entities.Enemy;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.math.FlxPoint;

class ManhattanPath extends LeafNode {

	var started:Bool = false;
	var speed:Float;

	public function new(speed:Float) {
		this.speed = speed;
	}

	public function generatePath(enemy:Enemy, dest:FlxPoint, bundle:NavBundle):Array<FlxPoint> {
		var destinationTile = bundle.level.navigationLayer.getTileIndexByCoords(dest);
        var destinationTileCoords = bundle.level.navigationLayer.getTileCoordsByIndex(destinationTile, true);
        var points = bundle.level.navigationLayer.findPath(enemy.getMidpoint(), destinationTileCoords, FlxTilemapDiagonalPolicy.NONE);
        return points;
	}

	override public function init(context:BTContext) {
		super.init(context);
		started = false;
	}

	override public function process(delta:Float):NodeStatus {
		var enemy = cast(context.get("enemy"), Enemy);

		if (!started) {
			started = true;
			if (context.get("target") == null) {
				return FAIL;
			}

			var points = generatePath(enemy, context.get("target"), context.get("navBundle"));
			if (points == null || points.length == 0) {
				return FAIL;
			}

			enemy.path.start(points, speed);
		} else {
			if (enemy.path.finished || enemy.path.nodes.length == 0) {
				started = false;
				return SUCCESS;
			}
		}

		return RUNNING;
	}
}