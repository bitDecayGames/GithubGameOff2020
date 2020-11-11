package behavior.movement;

import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import entities.Enemy;

interface MovementBehavior {
	public function generatePath(e:Enemy, bundle:NavBundle):Array<FlxPoint>;
}