package entities;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class HitboxTextInteract extends FlxSprite {

    public function new(_position:FlxPoint, _size:FlxPoint) {
        super(_position.x, _position.y);
        makeGraphic(Std.int(_size.x), Std.int(_size.y), new FlxColor(0xFF884422));


		#if debug
        visible = true;
        #else 
        visible = false;
		#end
    }

    public function updatePostion(_position:FlxPoint){
        setPosition(_position.x, _position.y);
    }

}