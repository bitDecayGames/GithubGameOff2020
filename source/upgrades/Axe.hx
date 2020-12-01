package upgrades;

import flixel.FlxSprite;

class Axe extends Upgrade {
    public function new() {
        super();
        name = "Pickaxe";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [10]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "A smashing axe";
    }

    override public function overrides(name:String):Bool {
        if (name == "Shovel") {
            return true;
        }

        return false;
    }
}