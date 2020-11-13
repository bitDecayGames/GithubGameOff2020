package extensions;

import flixel.FlxObject;

class FlxObjectExt {
	static public function setMidpoint(o:FlxObject, x:Float, y:Float) {
		trace("My width: " + o.width);
		trace("My height: " + o.height);
		trace("My position x: " + o.x);
		trace("My position y: " + o.y);
		o.setPosition(x - o.width/2, y - o.height/2);
	}
}