package states;

import dialogbox.DialogManager;
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
import entities.Interactable;

class OutsideTheMinesState extends FlxState
{
	var player:Player;
	var hitboxes:Array<Hitbox> = new Array<Hitbox>();
	var loots:Array<Loot> = new Array<Loot>();
	var enemies:Array<Enemy> = new Array<Enemy>();

	public var currentLevel:Level;

	var moneyText:FlxText;
	var money:Int = 0;
	var playerHealthText:FlxText;

	var shader:Lighten;
	var lightFilter:ShaderFilter;

	var uiCamera:FlxCamera;
	var uiGroup:FlxGroup;

	var axe:FlxSprite;
	
	var dialogManager:dialogbox.DialogManager;

	override public function create()
	{
		super.create();

		#if debug
		FlxG.debugger.drawDebug = true;
		#end

		FlxCamera.defaultCameras = [FlxG.camera];

		uiCamera = new FlxCamera(0, 0, 320, 240);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);

		camera.pixelPerfectRender = true;

		FmodManager.PlaySong(FmodSongs.OutsideTheMines);

		currentLevel = new Level();
		add(currentLevel.debugLayer);
		add(currentLevel.navigationLayer);
		add(currentLevel.interactableLayer);

		var exitTiles = currentLevel.interactableLayer.getTileCoords(3, false);
		axe = new Interactable("axe", exitTiles[0]);
		add(axe);

		player = new Player(null, new FlxPoint(FlxG.width/2, FlxG.height/2));
		add(player);

		moneyText = new FlxText(1, 1, 1000, "Money: ", 10);
		moneyText.cameras = [uiCamera];
		add(moneyText);
		playerHealthText = new FlxText(1, 15, 1000, "Health: ", 10);
		playerHealthText.cameras = [uiCamera];
		add(playerHealthText);
		
		dialogManager = new DialogManager(this, uiCamera);
		dialogManager.loadDialog(0);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		dialogManager.update();
		
		if (FlxG.keys.justPressed.Z) {
			
		}

		var shopVolumeRadius = 100;
		var distanceFromShop = player.getPosition().distanceTo(axe.getPosition());
		var shopVolume = Math.max(0, 1-(distanceFromShop/shopVolumeRadius));
		trace("Shop volume: " + shopVolume);
		FmodManager.SetEventParameterOnSong("ShopVolume", shopVolume);

		moneyText.text = "Money: " + money;
		playerHealthText.text = "Health: " + player.health;
	}

	override public function onFocus() {
		super.onFocus();
		FmodManager.UnpauseSong();
	}

	override public function onFocusLost() {
		super.onFocusLost();
		FmodManager.PauseSong();
	}
}
