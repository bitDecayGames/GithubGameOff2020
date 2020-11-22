package upgrades;

import flixel.FlxSprite;

class Shovel extends Upgrade {
    public function new() {
        super();
        loadGraphic(AssetPaths.shovel__png, true, 16, 16);

        animation.add("inventory", [0]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "A basic shovel";
    }
}