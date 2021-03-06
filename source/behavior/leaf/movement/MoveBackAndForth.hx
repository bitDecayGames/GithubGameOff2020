package behavior.leaf.movement;

import flixel.FlxG;
import flixel.math.FlxVector;
import flixel.FlxObject;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import behavior.tree.BTContext;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import behavior.tree.LeafNode;
import behavior.tree.NodeStatus;

class MoveBackAndForth extends LeafNode {

	var started:Bool = false;

	public function new() {}

	public function generatePath(spr:FlxSprite, dest:FlxPoint, bundle:NavBundle):Array<FlxPoint> {
		var destinationTile = bundle.level.navigationLayer.getTileIndexByCoords(dest);
        var destinationTileCoords = bundle.level.navigationLayer.getTileCoordsByIndex(destinationTile, true);
        var points = bundle.level.navigationLayer.findPath(spr.getMidpoint(), destinationTileCoords, FlxTilemapDiagonalPolicy.NONE);
        return points;
	}

	override public function init(context:BTContext) {
		super.init(context);
		started = false;
	}

	override public function doProcess(delta:Float):NodeStatus {
        var self = cast(context.get("self"), FlxSprite);
		var speed = cast(context.get("speed"), Float);

		var direction = cast(context.get("direction"), FlxVector);
        var bundle = cast(context.get("navBundle"), NavBundle);

		self.velocity.set(direction.x * speed, direction.y * speed);

		// we likely want to let some master collision controller handle this to
		// avoid having lots of calls to collide every frame
		if (FlxG.collide(bundle.level.navigationLayer, self)) {
			direction.scale(-1);
			return SUCCESS;
		} else {
			return RUNNING;
		}
	}
}