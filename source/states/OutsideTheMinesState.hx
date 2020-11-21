package states;

import haxe.Timer;
import flixel.tweens.FlxTween;
import shaders.MosaicManager;
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

class OutsideTheMinesState extends BaseState
{
	var player:Player;

	var moneyText:FlxText;
	var money:Int = 0;
	var playerHealthText:FlxText;

	var mosaicShaderManager:MosaicManager;
	var mosaicFilter:ShaderFilter;

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

		mosaicShaderManager = new MosaicManager();
		mosaicFilter = new ShaderFilter(mosaicShaderManager.shader);
		camera.setFilters([mosaicFilter]);
		uiCamera.setFilters([mosaicFilter]);
		
		// mosaicShaderManager.setStrength(5, 5);

		camera.alpha = 0;
		uiCamera.alpha = 0;
		
		FmodManager.StopSongImmediately();

		FmodManager.PlaySong(FmodSongs.OutsideTheMines);

		var fallSoundDelay = 2000;
		var fadeInDelay = fallSoundDelay + 6000;
		var standUpDelay = 2000;

		Timer.delay(() -> {
			FmodManager.PlaySoundOneShot(FmodSFX.PlayerFall);
		}, fallSoundDelay);


		Timer.delay(() -> {

			camera.fade(FlxColor.BLACK, 1.5, true);
			uiCamera.fade(FlxColor.BLACK, 1.5, true);
			
			camera.alpha = 1;
			uiCamera.alpha = 1;

			FlxTween.num(15, 1, 3, {}, function(v)
				{
					mosaicShaderManager.setStrength(v, v);
				}).onComplete = (t) -> {
					camera.setFilters([]);
					uiCamera.setFilters([]);
					
					Timer.delay(() -> {
						player.setControlsActive(true);
						dialogManager = new DialogManager(this, uiCamera);
						dialogManager.loadDialog(0);
					}, standUpDelay);
				};
		}, fadeInDelay);

		currentLevel = new Level();
		add(currentLevel.debugLayer);
		add(currentLevel.navigationLayer);
		add(currentLevel.interactableLayer);

		var exitTiles = currentLevel.interactableLayer.getTileCoords(3, false);
		axe = new Interactable("axe", exitTiles[0]);
		add(axe);

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		add(player);

		player.setControlsActive(false);

		moneyText = new FlxText(1, 1, 1000, "Money: ", 10);
		moneyText.cameras = [uiCamera];
		add(moneyText);
		playerHealthText = new FlxText(1, 15, 1000, "Health: ", 10);
		playerHealthText.cameras = [uiCamera];
		add(playerHealthText);
		
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (dialogManager != null){
			dialogManager.update();
		}
		
		if(FlxG.keys.justPressed.N) {
			FmodFlxUtilities.TransitionToState(new PlayState());
        	FmodManager.StopSoundImmediately("typewriterSoundId");
		}

		if (FlxG.keys.justPressed.Z) {
			
		}

		var shopVolumeRadius = 100;
		var distanceFromShop = player.getPosition().distanceTo(axe.getPosition());
		// Dynamic volume commented out for now
		// var shopVolume = Math.max(0, 1-(distanceFromShop/shopVolumeRadius));
		var shopVolume = 1;
		trace("Shop volume: " + shopVolume);
		FmodManager.SetEventParameterOnSong("ShopVolume", shopVolume);

		moneyText.text = "Money: " + money;
		playerHealthText.text = "Health: " + player.health;
	}
}
