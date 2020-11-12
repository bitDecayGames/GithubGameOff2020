package behavior.aggression;

import entities.Enemy;

interface AggressionBehavior {
	public function trigger(enemy:Enemy, bundle:NavBundle):Bool;
}