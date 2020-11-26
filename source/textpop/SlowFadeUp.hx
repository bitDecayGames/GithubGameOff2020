package textpop;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import com.bitdecay.textpop.style.Style;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class SlowFadeUp implements Style {

	var color:FlxColor;
	var fadeDuration:Float;

	public function new(?_color:FlxColor = FlxColor.WHITE, ?_fadeDuration:Float = 3) {
		color = _color;
		fadeDuration = _fadeDuration;
	}

	public function Stylize(obj:FlxObject):FlxTween {
		var flxObj:FlxObject = obj;
		var textObj = cast(obj, FlxText);
		textObj.color = color;
		var tween = FlxTween.tween(flxObj, { y: flxObj.y - 60, alpha: 0}, fadeDuration);
		return tween;
	}
}