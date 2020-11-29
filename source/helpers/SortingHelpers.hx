package helpers;

import flixel.addons.display.FlxTiledSprite;
import flixel.FlxObject;
import flixel.FlxBasic;

class SortingHelpers {
    public static inline var SORT_TO_TOP = 999;
    public static inline var SORT_TO_BOTTOM = 998;

    public static function SortByY(Order:Int, basic1:FlxBasic, basic2:FlxBasic):Int {
        var result:Int = 0;

        if (basic1.ID == SORT_TO_TOP) {
            return -Order;
        }

        if (basic2.ID == SORT_TO_TOP) {
            return Order;
        }


        if (basic1.ID == SORT_TO_BOTTOM) {
            return Order;
        }

        if (basic2.ID == SORT_TO_BOTTOM) {
            return -Order;
        }

        // XXX: This is mostly just to sort the escape rope on top of everything
        if (Std.downcast(basic1, FlxTiledSprite) != null) {
            return -Order;
        } else if (Std.downcast(basic2, FlxTiledSprite) != null) {
            return Order;
        }

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