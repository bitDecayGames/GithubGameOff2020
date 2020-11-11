package behavior;

import entities.Player;
import level.Level;

class NavBundle {
	public var level:Level;
	public var player:Player;

	public function new(level:Level, player:Player) {
		this.level = level;
		this.player = player;
	}
}