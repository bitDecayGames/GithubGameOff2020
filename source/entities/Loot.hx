package entities;

import flixel.math.FlxMath;
import helpers.MathHelpers;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Loot extends FlxSprite {

    var loopDropRadius = 25;

    public function new(_x:Float, _y:Float) {
        super();
        x = _x;
        y = _y;

        // Filler art
        makeGraphic(Std.int(5), Std.int(5), FlxColor.GREEN);

        // Calculate final drop point
        var theta = Math.random() * 2 * Math.PI;
        var finalX = _x + loopDropRadius * Math.cos(theta);
        var finalY = _y + loopDropRadius * Math.sin(theta);
        var randomPointAroundPlayer = new FlxPoint(finalX, finalY);

        // Create the path for it to follow
        path = new FlxPath();
        var initialPoint = new FlxPoint(x, y);
        var midpoint = MathHelpers.GetMidpoint(initialPoint, randomPointAroundPlayer);
        var topOfArc = FlxMath.minInt(Std.int(randomPointAroundPlayer.y), Std.int(randomPointAroundPlayer.y));
        midpoint.y = topOfArc-10;
        var points:Array<FlxPoint> = [midpoint, randomPointAroundPlayer];

        // Start the movement and add it to the state
        path.start(points, 100, FlxPath.FORWARD);
    }
}