package upgrades;

import flixel.FlxSprite;

class Shovel extends Upgrade {
    public function new() {
        super();
        name = "Shovel";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [9]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "A basic shovel";
    }
}