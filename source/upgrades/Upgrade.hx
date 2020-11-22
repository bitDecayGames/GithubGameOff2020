package upgrades;

import entities.Stats;
import flixel.FlxSprite;

class Upgrade extends FlxSprite {
    public function modifier(stats:Stats) {
        // No-op by default, override to add functionality
    }
}