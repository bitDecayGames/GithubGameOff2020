package upgrades;

import entities.Stats;
import flixel.FlxSprite;

class Upgrade extends FlxSprite {

    public var name:String;

    public function modifier(stats:Stats) {
        // No-op by default, override to add functionality
    }

    public function getDescription():String {
        return "No description";
    }

    public function overrides(name:String):Bool {
        return false;
    }

    public function overridedBy(name:String):Bool {
        return false;
    }
}