package level;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class Level {

	public var debugLayer:FlxTilemap;
	public var navigationLayer:FlxTilemap;
	public var interactableLayer:FlxTilemap;

	public function new() {
		var loader = new FlxOgmo3Loader(AssetPaths.levels__ogmo, AssetPaths.test__json);

		debugLayer = loader.loadTilemap(AssetPaths.filler__png, "debug");
		navigationLayer = loader.loadTilemap(AssetPaths.filler__png, "navigation");
		interactableLayer = loader.loadTilemap(AssetPaths.filler__png, "interactable");
	}
}