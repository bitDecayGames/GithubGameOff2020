package states;

import flixel.util.FlxSort;
import helpers.SortingHelpers;
import interactables.Shovel;
import interactables.Axe;
import textpop.SlowFadeDown;
import textpop.SlowFade;
import com.bitdecay.textpop.TextPop;
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
import entities.Shopkeep;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import interactables.Interactable;

class OutsideTheMinesState extends BaseState
{
	public inline static var SkipIntro:Bool = true;

	var skipIntro:Bool;

	var player:Player;

	var moneyText:FlxText;
	var money:Int = 5;
	var playerHealthText:FlxText;

	var mosaicShaderManager:MosaicManager;
	var mosaicFilter:ShaderFilter;

	var uiCamera:FlxCamera;
	var uiGroup:FlxGroup;

	var shovel:Interactable;
	var levelExit:Interactable;

	var dialogManager:dialogbox.DialogManager;

	public function new(?_skipIntro:Bool = false) {
		skipIntro = _skipIntro;
		super();
	}

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

		FmodManager.StopSongImmediately();
		FmodManager.PlaySong(FmodSongs.OutsideTheMines);

		currentLevel = new Level(AssetPaths.outsideTheMines__json);
		// add(currentLevel.debugLayer);
		add(currentLevel.groundLayer);
		add(currentLevel.navigationLayer);
		currentLevel.interactableLayer.alpha = 0;
		add(currentLevel.interactableLayer);

		var itemTiles = currentLevel.interactableLayer.getTileCoords(3, false);
		shovel = new Shovel(itemTiles[0]);
		addInteractable(shovel);

		var exitTiles = currentLevel.interactableLayer.getTileCoords(4, false);
		levelExit = new Rope(exitTiles[0]);
		addInteractable(levelExit);

		var shopkeepTiles = currentLevel.interactableLayer.getTileCoords(2, false);
		var shopkeep = new Shopkeep(shopkeepTiles[0]);
		worldGroup.add(shopkeep);

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		worldGroup.add(player);

		// This will be set in state eventually
		player.setCanAttack(false);

		playerHealthText = new FlxText(1, 1, 1000, "Health: ", 10);
		playerHealthText.cameras = [uiCamera];
		add(playerHealthText);
		moneyText = new FlxText(1, 15, 1000, "Money: ", 10);
		moneyText.cameras = [uiCamera];
		add(moneyText);

		add(worldGroup);

		if (skipIntro){
			camera.fade(FlxColor.BLACK, 1.5, true);
			uiCamera.fade(FlxColor.BLACK, 1.5, true);
			dialogManager = new DialogManager(this, uiCamera);
			dialogManager.loadDialog(0);
		} else {

			player.setControlsActive(false);

			player.animation.play("faceplant");

			camera.setFilters([mosaicFilter]);
			uiCamera.setFilters([mosaicFilter]);

			camera.alpha = 0;
			uiCamera.alpha = 0;

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
							dialogManager = new DialogManager(this, uiCamera);
							dialogManager.loadDialog(0);
							player.animation.play("faceplant_get_up");
						}, standUpDelay);
					};
			}, fadeInDelay);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		FmodManager.Update();

		FlxG.collide(currentLevel.navigationLayer, player);

		if (dialogManager != null){
			dialogManager.update();
		}

		if(FlxG.keys.justPressed.N) {
			FmodFlxUtilities.TransitionToState(new PlayState());
        	FmodManager.StopSoundImmediately("typewriterSoundId");
		}

		if (FlxG.keys.justPressed.U) {
			player.setCanAttack(true);
		}

		if (FlxG.keys.justPressed.MINUS) {
			money--;
		}

		if (FlxG.keys.justPressed.PLUS) {
			money++;
		}

		var shopVolumeRadius = 100;
		var distanceFromShop = player.getPosition().distanceTo(shovel.getPosition());
		// Dynamic volume commented out for now
		// var shopVolume = Math.max(0, 1-(distanceFromShop/shopVolumeRadius));
		var shopVolume = 1;
		FmodManager.SetEventParameterOnSong("ShopVolume", shopVolume);

		moneyText.text = "Money: " + money;
		playerHealthText.text = "Health: " + player.health;


		FlxG.overlap(interactables, hitboxes, interactWithItem);
		
		worldGroup.sort(SortingHelpers.SortByY, FlxSort.ASCENDING);
	}

	private function interactWithItem(interactable:Interactable, hitbox:Hitbox) {
		trace("intreaCTED");
		if (!interactable.hasBeenHitByThisHitbox(hitbox)) {
			if (interactable.name == "Rope") {
				if (!isTransitioningStates){
					isTransitioningStates = true;
					dialogManager.stopSounds();
					player.animation.play("climb_down");
					camera.fade(FlxColor.BLACK, 2, false, null, true);
					uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
					FmodManager.StopSoundImmediately("attack");
					player.stopAttack();
					FmodFlxUtilities.TransitionToStateAndStopMusic(new PlayState());
					player.setPosition(interactable.x+4, interactable.y+4);
				}
			} else {
				if (money >= interactable.cost){
					money -= interactable.cost;
					interactable.onInteract(player);
					TextPop.pop(Std.int(40), Std.int(30), "-$"+interactable.cost, new SlowFadeDown(FlxColor.RED), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchase);
				} else {
					TextPop.pop(Std.int(player.x), Std.int(player.y), "Not enough money", new SlowFade(), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
				}
			}
			interactable.trackHitbox(hitbox);
		}
	}
}
