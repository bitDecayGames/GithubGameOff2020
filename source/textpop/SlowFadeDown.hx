package textpop;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import com.bitdecay.textpop.style.Style;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class SlowFadeDown implements Style {

	public function new() {}

	public function Stylize(obj:FlxObject):FlxTween {
		var flxObj:FlxObject = obj;
		var brokeText = cast(obj, FlxText);
		var tween = FlxTween.tween(flxObj, { y: flxObj.y + 60, alpha: 0}, 3);
		return tween;
	}
}