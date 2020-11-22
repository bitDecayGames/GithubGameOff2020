package interactables;

import upgrades.Upgrade;
import flixel.util.FlxColor;
import entities.Hitbox;
import textpop.SlowFade;
import com.bitdecay.textpop.TextPop;
import entities.Player;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Interactable extends FlxSprite {

    public var name:String;
    public var cost:Int;

    var containedUpgrade:() -> Upgrade;

    var collidedHitboxes:Map<Hitbox, Bool> = new Map<Hitbox, Bool>();

    public function new(_position:FlxPoint) {
        // accounting for known half-width and half-height here
        // assume we are placing loot based on center
        super(_position.x, _position.y);
    }

    public function onInteract(_player:Player) {
        // Remove from world
        destroy();

        // Transfer general attributes to player/state
        if (containedUpgrade != null) {
            _player.addUpgrade(containedUpgrade);
        }

        // Display text
        TextPop.pop(Std.int(_player.x), Std.int(_player.y), name, new SlowFade(new FlxColor(0xFF54f542)), 10);
    }


    public function trackHitbox(hitbox:Hitbox) {
        collidedHitboxes.set(hitbox, true);
    }

    public function hasBeenHitByThisHitbox(hitbox:Hitbox):Bool{
        return collidedHitboxes.get(hitbox);
    }
}