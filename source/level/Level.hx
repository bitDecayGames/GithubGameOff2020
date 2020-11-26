package level;

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

	private static var levelCache = new Map<Int, Map<Int, EnemyCache>>();

	public var debugLayer:FlxTilemap;
	public var navigationLayer:FlxTilemap;
	public var interactableLayer:FlxTilemap;
	public var groundLayer:FlxTilemap;
	public var foregroundLayer:FlxTilemap;

	public var enemyMakers = new Array<(PlayState) -> Player -> Enemy>();

	public static function clearCache() {
		levelCache.clear();
	}

	public function new(level:String, depth:Int) {

		if (!levelCache.exists(depth)) {
			levelCache.set(depth, new Map<Int, EnemyCache>());
		}

		var loader = new FlxOgmo3Loader(AssetPaths.levels__ogmo, level);

		debugLayer = loader.loadTilemap(AssetPaths.filler__png, "debug");
		interactableLayer = loader.loadTilemap(AssetPaths.interactables__png, "interactable");
		foregroundLayer = loader.loadTilemap(AssetPaths.tiles__png, "foreground");

		trace("Loading level with set: " + Statics.CurrentSet);

		switch (Statics.CurrentSet){
			case 1:
				navigationLayer = loader.loadTilemap(AssetPaths.tiles__png, "navigation");
				groundLayer = loader.loadTilemap(AssetPaths.tiles__png, "ground");
			case 2:
				navigationLayer = loader.loadTilemap(AssetPaths.tiles2__png, "navigation");
				groundLayer = loader.loadTilemap(AssetPaths.tiles2__png, "ground");
		}

		var cache = levelCache.get(depth);

		loader.loadEntities((entityData) -> {
			trace(entityData);
			if (cache.exists(entityData.id)) {
				// load type, deadness, and position here
				var entry = cache.get(entityData.id);
				if (!entry.spawned) {
					// this enemy was never spawned, so do nothing;
					return;
				}

				trace('enemy ${entityData.id} already cached at loc: ${entry.position} and deadness: ${entry.dead}');
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
				var spawnRate:Float = 80;
				var pos = FlxPoint.get();
				if ( FlxG.random.float() * 100.0 > spawnRate ) {
					// we didn't roll high enough to spawn enemy, SKIP
					trace('${entityData.name}:${entityData.id} skipped');
					cache.set(entityData.id, new EnemyCache(depth, entityData.id, false, true, null, null));
				} else {
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
}