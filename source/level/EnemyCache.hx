package level;

import entities.Player;
import entities.Enemy;
import states.PlayState;
import flixel.math.FlxPoint;

class EnemyCache {
    public var depth = -1;
    public var id = -1;
    public var spawned:Bool;
    public var dead:Bool;
    public var position:FlxPoint;
    public var maker:(PlayState) -> Player -> Enemy;

    public function new(depth:Int, id:Int, spawned:Bool, dead:Bool, position:FlxPoint, maker:(PlayState) -> Player -> Enemy) {
        this.depth = depth;
        this.id = id;
        this.spawned = spawned;
        this.dead = dead;
        this.position = position;
        this.maker = maker;
    }
}