package entities;

import flixel.math.FlxMath;
import helpers.MathHelpers;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxG;

class Loot extends FlxSprite {

    public var coinType:String;
    public var coinValue:Int;

    var loopDropRadius = 25;

    public function new(_x:Float, _y:Float) {
        // accounting for known half-width and half-height here
        // assume we are placing loot based on center
        super(_x + 4, _y + 4);

        var random = Math.random();
        if (random < .8){
            coinType = "silver";
            coinValue = 1;
        } else {
            coinType = "gold";
            coinValue = 5;
        }

        loadCoinGraphic(coinType);
        animation.add("spin", [0,1,2,3,4,5], 10);
        animation.play("spin");


        var boundaryBuffer = 24;
        var inventoryBuffer = 36;

        // Calculate final drop point
        var theta = Math.random() * 2 * Math.PI;
        var finalX = Math.min(Math.max(boundaryBuffer, _x + loopDropRadius * Math.cos(theta)), FlxG.width-boundaryBuffer);
        var finalY = Math.min(Math.max(boundaryBuffer, _y + loopDropRadius * Math.sin(theta)), FlxG.height-boundaryBuffer-inventoryBuffer);
        var randomPointAroundPlayer = new FlxPoint(finalX, finalY);

        // Create the path for it to follow
        path = new FlxPath();
        var initialPoint = new FlxPoint(x, y);
        var midpoint = MathHelpers.GetMidpoint(initialPoint, randomPointAroundPlayer);
        var topOfArc = FlxMath.minInt(Std.int(randomPointAroundPlayer.y), Std.int(randomPointAroundPlayer.y));
        midpoint.y = topOfArc-10;
        var points:Array<FlxPoint> = [getPosition(), midpoint, randomPointAroundPlayer];

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