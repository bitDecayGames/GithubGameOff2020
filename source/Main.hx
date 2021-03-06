package;

import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.util.FlxColor;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.LoadFmodState;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.fixedTimestep = false;
		Configure.initAnalytics();
		// Bitlytics.Instance().Pause();
		addChild(new FlxGame(320, 272, LoadFmodState, 1, 60, 60, true, false));
		FlxG.mouse.useSystemCursor = true;
		trace("Starting game");
	}
}
