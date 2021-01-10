package textfx;

import com.bitdecay.lucidtext.ModifiableOptions;
import flixel.text.FlxText;
import com.bitdecay.lucidtext.effect.Effect;
import com.bitdecay.lucidtext.properties.Setters;


class Pulse implements Effect {
	public var speed:Float = 1;
	public var size:Float = 1.5;

	public function new() {}

	public function getUserProperties():Map<String, PropSetterFunc> {
		return [
			"speed" => Setters.setFloat,
			"size" => Setters.setFloat,
		];
	}

	public function apply(o:FlxText, i:Int):EffectUpdater {
		var mod = 1;
		var localSpeed = speed;
		var localSize = size;
		var target = localSize;
		return (delta) -> {

			if (mod == 1) {
				if (o.scale.y >= target) {
					target = 1;
					mod = -1;
				}
			} else {
				if (o.scale.y <= target) {
					target = localSize;
					mod = 1;
				}
			}

			o.scale.x += localSpeed * delta * mod;
			o.scale.y += localSpeed * delta * mod;

			return true;
		}
	}

	public function begin(ops:ModifiableOptions):Void {}
	public function end(ops:ModifiableOptions):Void {}
}