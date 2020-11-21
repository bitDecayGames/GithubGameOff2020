package states;

import interactables.Interactable;
import entities.Stats;
import haxe.Timer;
import flixel.tile.FlxTilemap;
import flixel.FlxBasic;
import flixel.util.FlxSort;
import com.bitdecay.textpop.TextPop;
import states.OutsideTheMinesState;
import entities.Rope;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import haxefmod.flixel.FmodFlxUtilities;
import shaders.Lighten;
import openfl.filters.ShaderFilter;
import level.Level;
import flixel.text.FlxText;
import entities.Loot;
import helpers.MathHelpers;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.FlxSprite;
import haxe.display.Display.Package;
import entities.Hitbox;
import flixel.FlxG;
import entities.Player;
import entities.Enemy;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import textpop.SlowFade;

class BaseState extends FlxState
{
	public var currentLevel:Level;

	var hitboxes:FlxTypedGroup<Hitbox> = new FlxTypedGroup<Hitbox>();
	var loots:FlxTypedGroup<Loot> = new FlxTypedGroup<Loot>();
	var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();
	var projectiles:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var interactables:FlxTypedGroup<Interactable> = new FlxTypedGroup<Interactable>();

	var worldGroup:FlxGroup = new FlxGroup();

	public function addHitbox(hitbox:Hitbox) {
		hitboxes.add(hitbox);
		add(hitbox);
	}

	public function addLoot(loot:Loot) {
		loots.add(loot);
		worldGroup.add(loot);
	}

	public function addProjectile(proj:FlxSprite) {
		projectiles.add(proj);
		worldGroup.add(proj);
	}

	public function addInteractable(interactable:Interactable) {
		interactables.add(interactable);
		worldGroup.add(interactable);
	}

	override public function onFocus() {
		super.onFocus();
		FmodManager.UnpauseSong();
		// Hack to deal with the lack of global sound pausing
		FmodManager.UnpauseSound("typewriterSoundId");
	}

	override public function onFocusLost() {
		super.onFocusLost();
		FmodManager.PauseSong();
		// Hack to deal with the lack of global sound pausing
		FmodManager.PauseSound("typewriterSoundId");
	}
}
