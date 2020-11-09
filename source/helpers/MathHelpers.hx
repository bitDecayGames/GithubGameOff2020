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

    public static function GetMidpoint(point1:FlxPoint, point2:FlxPoint):FlxPoint {
        var pointsAdded = new FlxPoint(point1.x+point2.x, point1.y+point2.y);
        return new FlxPoint(pointsAdded.x/2, pointsAdded.y/2);
    }
}