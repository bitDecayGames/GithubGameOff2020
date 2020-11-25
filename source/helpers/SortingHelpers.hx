package helpers;

import flixel.FlxObject;
import flixel.FlxBasic;

class SortingHelpers {
    public static function SortByY(Order:Int, basic1:FlxBasic, basic2:FlxBasic):Int {
        var result:Int = 0;

        var obj1:FlxObject = cast (basic1, FlxObject);
        var obj2:FlxObject = cast (basic2, FlxObject);
        if ((obj1.y + obj1.height / 2) < obj2.y + obj2.height / 2)
        {
            result = Order;
        }
        else if ((obj1.y + obj1.height / 2) > (obj2.y + obj2.height / 2))
        {
            result = -Order;
        }

        return result;
    }
}