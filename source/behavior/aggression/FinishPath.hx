package behavior.aggression;

import entities.Enemy;

class FinishPath implements AggressionBehavior {
	public function new() {}

	public function trigger(enemy:Enemy, bundle:NavBundle):Bool {
		// nothing interrupts
		return false;
	}
}