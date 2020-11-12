package behavior.movement;

import flixel.FlxObject;
import entities.Enemy;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.math.FlxPoint;

class ManhattanPath implements MovementBehavior {
	var dest:FlxObject;

	public function new(dest:FlxObject) {
		this.dest = dest;
	}

	public function generatePath(enemy:Enemy, bundle:NavBundle):Array<FlxPoint> {
		var destinationTile = bundle.level.navigationLayer.getTileIndexByCoords(dest.getMidpoint());
        var destinationTileCoords = bundle.level.navigationLayer.getTileCoordsByIndex(destinationTile, true);
        var points = bundle.level.navigationLayer.findPath(enemy.getMidpoint(), destinationTileCoords, FlxTilemapDiagonalPolicy.NONE);
        return points;
	}
}