package helpers;

import flixel.math.FlxPoint;

class MathHelpers {
    public static function NormalizeVector(vector:FlxPoint):FlxPoint {
        var vectorMagnitude = Math.sqrt(vector.x*vector.x + vector.y*vector.y);

        var normalizedX:Float;
        if (vector.x == 0){
            normalizedX = 0;
        } else {
            normalizedX = vector.x/vectorMagnitude;
        }

        var normalizedY:Float;
        if (vector.y == 0){
            normalizedY = 0;
        } else {
            normalizedY = vector.y/vectorMagnitude;
        }

        return new FlxPoint(normalizedX, normalizedY);
    }
}