package entities;

import flixel.math.FlxMath;
import helpers.MathHelpers;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Interactable extends FlxSprite {

    public var item:String;

    public function new(_item:String, _position:FlxPoint) {
        // accounting for known half-width and half-height here
        // assume we are placing loot based on center
        super(_position.x, _position.y);
        item = _item;

        

        loadSpriteData(_item);
    }

    private function loadSpriteData(_item:String){
        switch _item {
            case "axe":
                super.loadGraphic(AssetPaths.axe__png, true, 16, 16);
            default: 
                trace("Unable to find match for item: " + _item);
        }
    }
}