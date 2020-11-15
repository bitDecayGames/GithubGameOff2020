package entities;

import flixel.math.FlxMath;
import helpers.MathHelpers;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Loot extends FlxSprite {

    public var coinType:String;
    public var coinValue:Int;

    var loopDropRadius = 25;

    public function new(_x:Float, _y:Float) {
        super();
        x = _x;
        y = _y;

        var random = Math.random();
        if (random < .5){
            coinType = "silver";
            coinValue = 1;
        } else {
            coinType = "gold";
            coinValue = 5;
        }

        loadCoinGraphic(coinType);
        animation.add("spin", [0,1,2,3,4,5], 10);
        animation.play("spin");


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

    private function loadCoinGraphic(_coinType:String){
        if (_coinType == "silver") {
            super.loadGraphic(AssetPaths.silver_coin__png, true, 8, 8);
        } else {
            super.loadGraphic(AssetPaths.gold_coin__png, true, 8, 8);
        }
    }
}