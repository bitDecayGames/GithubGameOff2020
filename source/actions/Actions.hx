package actions;

import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.FlxObject;
import flixel.input.FlxSwipe;
import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class Actions {
	public var up = new FlxActionDigital();
	public var down = new FlxActionDigital();
	public var left = new FlxActionDigital();
	public var right = new FlxActionDigital();

	public var attack = new FlxActionDigital();

	public function new() {
		up.addKey(FlxKey.W,  PRESSED);
		up.addKey(FlxKey.UP, PRESSED);
		up.addGamepad(DPAD_UP, PRESSED);

		down.addKey(FlxKey.S, PRESSED);
		down.addKey(FlxKey.DOWN, PRESSED);
		down.addGamepad(DPAD_DOWN, PRESSED);

		left.addKey(FlxKey.A, PRESSED);
		left.addKey(FlxKey.LEFT, PRESSED);
		left.addGamepad(DPAD_LEFT, PRESSED);

		right.addKey(FlxKey.D, PRESSED);
		right.addKey(FlxKey.RIGHT, PRESSED);
		right.addGamepad(DPAD_RIGHT, PRESSED);

		attack.addKey(FlxKey.Z, JUST_PRESSED);
		attack.addGamepad(A, JUST_PRESSED);
	}
}