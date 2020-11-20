package entities;

import flixel.math.FlxPoint;
import flixel.FlxSprite;

class AcidShot extends FlxSprite {


    public function new(x:Float, y:Float, direction:Float, speed:Float) {
        super(x, y);

        loadGraphic(AssetPaths.snake__png, true, 16, 16);

        animation.add("go", [36], 1, true);
        animation.play("go");

        angle = direction;

        // this needs to be set some other way
        var travel = FlxPoint.get(1, 0).rotate(FlxPoint.get(), direction);
        travel.scale(speed);
        velocity.set(travel.x, travel.y);
    }
}