package behavior.aggression;

import flixel.FlxObject;
import entities.Enemy;

class Proximity {
	var other:FlxObject;
	var proximity:Float;

	public function new(other:FlxObject, proximity:Float) {
		this.other = other;
		this.proximity = proximity;
	}

	public function trigger(enemy:Enemy, bundle:NavBundle):Bool {
		return enemy.getMidpoint().distanceTo(other.getMidpoint()) <= proximity;
	}
}