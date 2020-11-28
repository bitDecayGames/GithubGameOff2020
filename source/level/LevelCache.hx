package level;

import flixel.math.FlxPoint;

class LevelCache {
    public var depth:Int;
    public var entrance:FlxPoint;
    public var exit:FlxPoint;
    public var enemies = new Map<Int, EnemyCache>();

    public function new(depth:Int) {
        this.depth = depth;
        exit = null;
        entrance = null;
        depth = -1;
    }
}