package level;

import entities.RopeUp;
import entities.Rope;
import flixel.FlxG;
import entities.Enemy;
import entities.enemies.Blob;
import entities.enemies.Snake;
import entities.enemies.Bat;
import flixel.math.FlxPoint;
import entities.Player;
import states.PlayState;
import entities.enemies.Rat;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class Level {

	private static var levelCache = new Map<Int, LevelCache>();

	public var debugLayer:FlxTilemap;
	public var navigationLayer:FlxTilemap;
	public var interactableLayer:FlxTilemap;
	public var groundLayer:FlxTilemap;
	public var foregroundLayer:FlxTilemap;

	public var upRope:RopeUp;
	public var downRope:Rope;

	public var enemyMakers = new Array<(PlayState) -> Player -> Enemy>();

	public static function clearCache() {
		levelCache.clear();
	}

	public function new(level:String, depth:Int) {

		if (!levelCache.exists(depth)) {
			levelCache.set(depth, new LevelCache(depth));
		}

		var loader = new FlxOgmo3Loader(AssetPaths.levels__ogmo, level);

		debugLayer = loader.loadTilemap(AssetPaths.filler__png, "debug");
		interactableLayer = loader.loadTilemap(AssetPaths.interactables__png, "interactable");
		foregroundLayer = loader.loadTilemap(AssetPaths.tiles__png, "foreground");

		var lCache = levelCache.get(depth);

		loader.loadEntities((entityData) -> {
			switch(entityData.name) {
				case "downrope":
					if (lCache.exit != null) {
						downRope = new Rope(lCache.exit);
					} else {
						downRope = new Rope(selectRandomPosFromNodes(entityData));
						lCache.exit = downRope.getPosition();
					}
				default:
					throw 'Unknown object found on "ropes" layer: ${entityData.name}';
			}
		}, "rope");

		if (levelCache.exists(depth-1)) {
			// our entrance location is the previous dephs exit location
			upRope = new RopeUp(levelCache.get(depth-1).exit);
		} else {
			upRope = new RopeUp(FlxPoint.get(100, 100));
		}

		trace("Loading level with set: " + Statics.CurrentSet);

		switch (Statics.CurrentSet){
			case 1:
				navigationLayer = loader.loadTilemap(AssetPaths.tiles__png, "navigation");
				groundLayer = loader.loadTilemap(AssetPaths.tiles__png, "ground");
			case 2:
				navigationLayer = loader.loadTilemap(AssetPaths.tiles2__png, "navigation");
				groundLayer = loader.loadTilemap(AssetPaths.tiles2__png, "ground");
		}

		var cache = levelCache.get(depth).enemies;

		loader.loadEntities((entityData) -> {
			if (cache.exists(entityData.id)) {
				// load type, deadness, and position here
				var entry = cache.get(entityData.id);
				if (!entry.spawned) {
					// this enemy was never spawned, so do nothing;
					return;
				}

				enemyMakers.push((playState, player) -> {
					var enemy = entry.maker(playState, player);
					if (entry.dead) {
						// TODO: instead of KILL, we want  to disable collisions and
						//       play the "dead" animation
						enemy.kill();
					}
					enemy.x = entry.position.x;
					enemy.y = entry.position.y;
					return enemy;
				});
			} else {
				var spawnRate:Float = entityData.values.SpawnRate;
				var roll = FlxG.random.float() * 100.0;

				var pos = FlxPoint.get();
				if (roll > spawnRate ) {
					// we didn't roll high enough to spawn enemy, SKIP
					trace('${entityData.name}:${entityData.id} skipped');
					cache.set(entityData.id, new EnemyCache(depth, entityData.id, false, true, null, null));
				} else {
					pos = selectRandomPosFromNodes(entityData);

					var cacheEntry = new EnemyCache(depth, entityData.id, true, false, pos, null);
					switch(entityData.name) {
						case "rat":
							cacheEntry.maker = (playState, player) -> {
								return new Rat(playState, player, FlxPoint.get(entityData.x, entityData.y), cacheEntry);
							};
						case "bat":
							cacheEntry.maker = (playState, player) -> {
								return new Bat(playState, player, FlxPoint.get(entityData.x, entityData.y), cacheEntry);
							};
						case "snake":
							cacheEntry.maker = (playState, player) -> {
								return new Snake(playState, player, FlxPoint.get(entityData.x, entityData.y), cacheEntry);
							};
						case "blob":
							cacheEntry.maker = (playState, player) -> {
								return new Blob(playState, player, FlxPoint.get(entityData.x, entityData.y), cacheEntry);
							};
						default:
							throw "unrecognized enemy with name: " + entityData.name;
					};
					cache.set(entityData.id, cacheEntry);
					enemyMakers.push(cacheEntry.maker);
				}
			}
		}, "spawners");
	}

	private function selectRandomPosFromNodes(entityData:EntityData):FlxPoint {
		var pos = FlxPoint.get();
		if (entityData.nodes == null) {
			pos.set(entityData.x, entityData.y);
			return pos;
		}

		var nodeIndex = FlxG.random.int(0, entityData.nodes.length);
		if (nodeIndex == entityData.nodes.length) {
			// this is past the end of the list, use the entity's position here
			// as it is NOT in the node list
			pos.x = entityData.x;
			pos.y = entityData.y;
		} else {
			var spawnNode = entityData.nodes[nodeIndex];
			pos.x = spawnNode.x;
			pos.y = spawnNode.y;
		}
		return pos;
	}
}