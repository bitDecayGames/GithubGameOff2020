package states;

import entities.Player;
import flixel.FlxState;

class PlayState extends FlxState
{
	var player:Player;

	override public function create()
	{
		super.create();

		FmodManager.PlaySong(FmodSongs.LetsGo);

		player = new Player(this);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
