package level;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class Level {

	public var debugLayer:FlxTilemap;
	public var navigationLayer:FlxTilemap;
	public var interactableLayer:FlxTilemap;
	public var groundLayer:FlxTilemap;
	public var foregroundLayer:FlxTilemap;

	public function new(level:String) {
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
	}
}