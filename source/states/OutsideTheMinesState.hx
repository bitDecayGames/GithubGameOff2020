package states;

import interactables.Shoe;
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

	public static inline var shovel_index = 1;
	public static inline var shoe_index = 3;
	public static inline var rope_index = 5;
	public static inline var shopkeep_index = 4;

	var skipIntro:Bool;

	var player:Player;

	var moneyText:FlxText;
	var playerHealthText:FlxText;

	var mosaicShaderManager:MosaicManager;
	var mosaicFilter:ShaderFilter;

	var uiCamera:FlxCamera;

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
		FlxG.autoPause = false;

		#if debug
		FlxG.debugger.drawDebug = true;
		#end

		FlxCamera.defaultCameras = [FlxG.camera];

		uiCamera = new FlxCamera(0, 0, 320, 240);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		add(uiGroup);
		setupHUD();

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

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		worldGroup.add(player);

		var itemTiles:Array<FlxPoint>;

		if (!player.hasUpgrade("Shovel")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(shovel_index, false);
			shovel = new Shovel(itemTiles[0]);
			addInteractable(shovel);
		}

		if (!player.hasUpgrade("SpeedClog")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(shoe_index, false);
			var shoe = new Shoe(itemTiles[0]);
			addInteractable(shoe);
		}

		var exitTiles = currentLevel.interactableLayer.getTileCoords(rope_index, false);
		levelExit = new Rope(exitTiles[0]);
		addInteractable(levelExit);

		var shopkeepTiles = currentLevel.interactableLayer.getTileCoords(shopkeep_index, false);
		var shopkeep = new Shopkeep(this, shopkeepTiles[0]);
		worldGroup.add(shopkeep);

		// This will be set in state eventually
		player.setCanAttack(false);

		add(worldGroup);
		add(uiGroup);

		dialogManager = new DialogManager(this, uiCamera);

		if (skipIntro || player.hasUpgrade("Shovel")){
			camera.fade(FlxColor.BLACK, 1.5, true);
			uiCamera.fade(FlxColor.BLACK, 1.5, true);

			if (!player.hasUpgrade("Shovel")){
				dialogManager.loadDialog(0);
			}
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
							dialogManager.loadDialog(0);
							player.animation.play("faceplant_get_up");
						}, standUpDelay);
					};
			}, fadeInDelay);
		}
	}

	private function setupHUD() {
		var hudBG = new FlxSprite(0, FlxG.height - 32);
		hudBG.makeGraphic(FlxG.width, 32, FlxColor.BLUE);
		uiGroup.add(hudBG);

		var textVerticalOffset = 7;
		var healthIcon = new FlxSprite(16 * 13, FlxG.height - 32);
		healthIcon.makeGraphic(32, 32, FlxColor.PINK);
		uiGroup.add(healthIcon);
		playerHealthText = new FlxText(16 * 15, FlxG.height - 32 + textVerticalOffset, 1000, "", 10);
		uiGroup.add(playerHealthText);

		var moneyIcon = new FlxSprite(16 * 16, FlxG.height - 32);
		moneyIcon.makeGraphic(32, 32, FlxColor.BROWN);
		uiGroup.add(moneyIcon);
		moneyText = new FlxText(16 * 18, FlxG.height - 32 + textVerticalOffset, 1000, "", 10);
		uiGroup.add(moneyText);
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
			Player.state.money--;
		}

		if (FlxG.keys.justPressed.PLUS) {
			Player.state.money++;
		}

		// var shopVolumeRadius = 100;
		// var distanceFromShop = player.getPosition().distanceTo(shovel.getPosition());
		// Dynamic volume commented out for now
		// var shopVolume = Math.max(0, 1-(distanceFromShop/shopVolumeRadius));
		// var shopVolume = 1;
		// FmodManager.SetEventParameterOnSong("ShopVolume", shopVolume);

		moneyText.text = "" + Player.state.money;
		playerHealthText.text = "" + player.health;


		FlxG.overlap(interactables, hitboxes, interactWithItem);

		worldGroup.sort(SortingHelpers.SortByY, FlxSort.ASCENDING);
	}

	private function interactWithItem(interactable:Interactable, hitbox:Hitbox) {
		if (!interactable.hasBeenHitByThisHitbox(hitbox)) {
			if (interactable.name == "Rope") {
				if (!player.hasUpgrade("Shovel")) {
					TextPop.pop(Std.int(200), Std.int(140), "You aren't ready", new SlowFadeDown(FlxColor.RED), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
					trace("Dialgomanager is done: " + dialogManager.isDone);
					if (dialogManager.isDone){
						dialogManager.loadDialog(1);
					}
				} else if (!isTransitioningStates){
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
				if (Player.state.money >= interactable.cost){
					Player.state.money -= interactable.cost;
					interactable.onInteract(player);
					TextPop.pop(Std.int(36), Std.int(20), "-$"+interactable.cost, new SlowFadeDown(FlxColor.RED), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchase);
					dialogManager.loadDialog(2);
				} else {
					TextPop.pop(Std.int(player.x), Std.int(player.y), "Not enough money", new SlowFade(), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
				}
			}
			interactable.trackHitbox(hitbox);
		}
	}

	override public function destroy() {
		// we don't want the player to get destroyed
		worldGroup.remove(player);
		for (int in interactables) {
			worldGroup.remove(int);
		}
		super.destroy();
	}
}
