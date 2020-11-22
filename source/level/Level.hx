package level;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class Level {

	public var debugLayer:FlxTilemap;
	public var navigationLayer:FlxTilemap;
	public var interactableLayer:FlxTilemap;
	public var groundLayer:FlxTilemap;

	public function new(level:String) {
		var loader = new FlxOgmo3Loader(AssetPaths.levels__ogmo, level);

		debugLayer = loader.loadTilemap(AssetPaths.filler__png, "debug");
		navigationLayer = loader.loadTilemap(AssetPaths.tiles__png, "navigation");
		interactableLayer = loader.loadTilemap(AssetPaths.filler__png, "interactable");
		groundLayer = loader.loadTilemap(AssetPaths.tiles__png, "ground");
	}
}