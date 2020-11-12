package extensions;

import flixel.FlxObject;

class FlxObjectExt {
	static public function setMidpoint(o:FlxObject, x:Float, y:Float) {
		o.setPosition(x - o.width/2, y - o.height/2);
	}
}