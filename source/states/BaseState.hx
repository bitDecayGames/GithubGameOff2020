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
	public var isTransitioningStates:Bool;

	var hitboxes:FlxTypedGroup<Hitbox> = new FlxTypedGroup<Hitbox>();
	var loots:FlxTypedGroup<Loot> = new FlxTypedGroup<Loot>();
	var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();
	var projectiles:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var interactables:FlxTypedGroup<Interactable> = new FlxTypedGroup<Interactable>();

	var worldGroup:FlxGroup = new FlxGroup();
	var uiGroup:FlxGroup = new FlxGroup();

	var moneyText:FlxText;
	var playerHealthText:FlxText;

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

	public function addUIElement(elem:FlxSprite) {
		uiGroup.add(elem);
	}

	function setupHUD() {
		var hudBG = new FlxSprite(0, FlxG.height - 32);
		hudBG.makeGraphic(FlxG.width, 32, FlxColor.BLUE);
		uiGroup.add(hudBG);

		var textVerticalOffset = 9;
		var healthIcon = new FlxSprite(16 * 13, FlxG.height - 32);
		healthIcon.loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);
		healthIcon.animation.add("frame", [0]);
		healthIcon.animation.play("frame");
		uiGroup.add(healthIcon);

		playerHealthText = new FlxText(16 * 15, FlxG.height - 32 + textVerticalOffset, 1000, "", 10);
		uiGroup.add(playerHealthText);

		var moneyIcon = new FlxSprite(16 * 16, FlxG.height - 32);
		moneyIcon.loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);
		moneyIcon.animation.add("frame", [6]);
		moneyIcon.animation.play("frame");
		uiGroup.add(moneyIcon);

		moneyText = new FlxText(16 * 18, FlxG.height - 32 + textVerticalOffset, 1000, "", 10);
		uiGroup.add(moneyText);
	}

	// override public function onFocus() {
		// super.onFocus();
		// FmodManager.UnpauseSong();
		// // Hack to deal with the lack of global sound pausing
		// FmodManager.UnpauseSound("typewriterSoundId");
	// }

	// override public function onFocusLost() {
		// super.onFocusLost();
		// FmodManager.PauseSong();
		// // Hack to deal with the lack of global sound pausing
		// FmodManager.PauseSound("typewriterSoundId");
	// }
}
