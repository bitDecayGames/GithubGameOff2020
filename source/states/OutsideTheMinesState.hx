package states;

import com.bitdecay.lucidtext.effect.EffectRegistry;
import flixel.math.FlxRect;
import com.bitdecay.lucidtext.TypeOptions;
import com.bitdecay.lucidtext.dialog.DialogOptions;
import flixel.input.keyboard.FlxKey;
import entities.GameState;
import entities.HitboxTextInteract;
import interactables.HeartJar;
import interactables.MatterConverter;
import flixel.input.mouse.FlxMouse;
import interactables.Shoe;
import flixel.util.FlxSort;
import helpers.SortingHelpers;
import interactables.Shovel;
import interactables.Light;
import interactables.Axe;
import textpop.SlowFadeUp;
import textpop.SlowFade;
import com.bitdecay.textpop.TextPop;
import haxe.Timer;
import flixel.tweens.FlxTween;
import shaders.MosaicManager;
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
import com.bitdecay.lucidtext.dialog.DialogManager;

class OutsideTheMinesState extends BaseState
{
	public inline static var SkipIntro:Bool = true;

	// some of these numbers are wacky because we are loading the tileset
	// in Ogmo as a 16x16 tileset.
	public static inline var shovel_index = 1;
	public static inline var pickaxe_index = 2;
	public static inline var shoe_index = 3;
	public static inline var rope_index = 5;
	public static inline var bulb_index = 8;
	public static inline var heartjar_index = 20;
	public static inline var matterconverter_index = 21;

	public static inline var shopkeep_index = 4;

	var skipIntro:Bool;

	var player:Player;

	var mosaicShaderManager:MosaicManager;
	var mosaicFilter:ShaderFilter;

	var uiCamera:FlxCamera;

	var shovel:Interactable;
	var levelExit:Interactable;

	var dialogManager:DialogManager;

	static var firstTime = true;

	public function new(?_skipIntro:Bool = false) {
		skipIntro = _skipIntro;
		super();
	}

	public static inline var typewriterSoundId = "TypewriterSound";

	public function playTypingSound() {
		FmodManager.PlaySoundAndAssignId(FmodSFX.Typewriter, typewriterSoundId);
	}

	public function stopTypingSound() {
		FmodManager.StopSoundImmediately(typewriterSoundId);
	}

	public function speedupTypingSound() {
		FmodManager.StopSoundImmediately(typewriterSoundId);
		FmodManager.PlaySoundAndAssignId(FmodSFX.TypewriterFast, typewriterSoundId);
	}

	override public function create()
	{
		super.create();
		FlxG.mouse.visible = false;

		#if debug
		FlxG.debugger.drawDebug = true;
		#end

		Statics.MatterConverterCharges = 0;

		FlxCamera.defaultCameras = [FlxG.camera];

		uiCamera = new FlxCamera(0, 0, 320, 240);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		add(uiGroup);
		setupHUD();

		camera.pixelPerfectRender = true;

		mosaicShaderManager = new MosaicManager();
		mosaicFilter = new ShaderFilter(mosaicShaderManager.shader);

		if (firstTime) {
			// we don't want to stop the music that the splash screen started
			firstTime = false;
		} else {
			// any other time we get here, stop the music and play our song
			FmodManager.StopSongImmediately();
			FmodManager.PlaySong(FmodSongs.OutsideTheMines);
		}

		// Clear any previous run
		Level.clearCache();

		currentLevel = new Level(AssetPaths.outsideTheMines__json, 0);
		// add(currentLevel.debugLayer);
		add(currentLevel.groundLayer);
		add(currentLevel.navigationLayer);
		currentLevel.interactableLayer.alpha = 0;
		add(currentLevel.interactableLayer);

		levelExit = currentLevel.downRope;
		addInteractable(levelExit);
		// This makes us collide with the tile that the downrope is at
		currentLevel.navigationLayer.setTile(Std.int(levelExit.x / 16), Std.int(levelExit.y / 16), 1);

		if (skipIntro){
			player = new Player(this, new FlxPoint(levelExit.x-16, levelExit.y));
			if (!player.hasUpgrade("Shovel")){
				player.addUpgrade(() -> return new upgrades.Shovel());
			}
		} else {
			player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		}

		player.rejuvenate();

		worldGroup.add(player);

		var itemTiles:Array<FlxPoint>;

		if (!player.hasUpgrade("Shovel")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(shovel_index, false);
			// offset by 16 since we are loading 16/32 tiles that in the editor are set one til
			// above where we want the collider in-game
			shovel = new Shovel(itemTiles[0]);
			add(shovel.priceText);
			addInteractable(shovel);
		}

		if (!player.hasUpgrade("Pickaxe")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(pickaxe_index, false);
			// offset by 16 since we are loading 16/32 tiles that in the editor are set one til
			// above where we want the collider in-game
			shovel = new Axe(itemTiles[0]);
			add(shovel.priceText);
			addInteractable(shovel);
		}

		if (!player.hasUpgrade("SpeedClog")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(shoe_index, false);
			var coords = itemTiles[0];
			var shoe = new Shoe(coords);
			add(shoe.priceText);
			addInteractable(shoe);
		}

		if (!player.hasUpgrade("Heart Jar")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(heartjar_index, false);
			var coords = itemTiles[0];
			var shoe = new HeartJar(coords);
			add(shoe.priceText);
			addInteractable(shoe);
		}

		if (!player.hasUpgrade("Matter Converter")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(matterconverter_index, false);
			var coords = itemTiles[0];
			var shoe = new MatterConverter(coords);
			add(shoe.priceText);
			addInteractable(shoe);
		}

		if (!player.hasUpgrade("LED Bulb")){
			itemTiles = currentLevel.interactableLayer.getTileCoords(bulb_index, false);
			var coords = itemTiles[0];
			var shoe = new Light(coords);
			add(shoe.priceText);
			addInteractable(shoe);
		}

		var shopkeepTiles = currentLevel.interactableLayer.getTileCoords(shopkeep_index, false);
		var shopkeep = new Shopkeep(this, shopkeepTiles[0]);
		worldGroup.add(shopkeep);

		if (!player.hasUpgrade("Shovel")){
			player.setCanAttack(false);
		}

		add(worldGroup);
		add(uiGroup);

		EffectRegistry.registerDefault("wave", {height: 4});

		var dialogOpts = new DialogOptions(new FlxRect(140, 5, 180, 90));
		dialogOpts.progressionKey = FlxKey.SPACE;
		dialogOpts.onTypingBegin = playTypingSound;
		dialogOpts.onTypingEnd = stopTypingSound;
		dialogOpts.onTypingSpeedUp = speedupTypingSound;

		var typeOpts = new TypeOptions(AssetPaths.slice__png, [4,4,12,12], 10, 8);

		dialogManager = new DialogManager(Dialogs.DialogMap, this, uiCamera, dialogOpts, typeOpts);
		add(dialogManager);

		if (skipIntro || player.hasUpgrade("Shovel")){
			camera.fade(FlxColor.BLACK, 1.5, true);
			uiCamera.fade(FlxColor.BLACK, 1.5, true);

			TextPop.pop(Std.int(player.x-80), Std.int(player.y), "Headlamp recharged", new SlowFadeUp(FlxColor.WHITE, 4), 10);
			FmodManager.PlaySoundOneShot(FmodSFX.LightRecharge);

			if (Statics.PlayerDied){
				Statics.PlayerDied = false;
				dialogManager.loadDialog(Dialogs.PlayerDied);
				var lostMoney = Std.int(Player.state.money / 2);
				Player.state.money -= lostMoney;
				TextPop.pop(Std.int(player.x-15), Std.int(player.y+20), "-$" +lostMoney, new SlowFadeUp(FlxColor.RED, 4), 10);
			} else if (!player.hasUpgrade("Shovel")){
				dialogManager.loadDialog(Dialogs.Intro);
			} else if (Statics.CurrentLightRadius > Statics.minLightRadius && Statics.CurrentLightRadius <= Statics.minLightRadius+20) {
				dialogManager.loadDialog(Dialogs.PlayerAlmostRanOutOfLight);
			} else if (Statics.CurrentLightRadius <= Statics.minLightRadius) {
				dialogManager.loadDialog(Dialogs.PlayerRanOutOfLight);
				var lostMoney = Std.int(Player.state.money / 2);
				Player.state.money -= lostMoney;
				TextPop.pop(Std.int(player.x-15), Std.int(player.y+20), "-$" +lostMoney, new SlowFadeUp(FlxColor.RED, 4), 10);
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
							dialogManager.loadDialog(Dialogs.Intro);
							player.animation.play("faceplant_get_up");
						}, standUpDelay);
					};
			}, fadeInDelay);
		}
	}

	override public function isShopkeepTalking():Bool {
		if (dialogManager != null){
			return dialogManager.isTyping();
		}
		return false;
	}

	override public function update(elapsed:Float) {
		Statics.CurrentLightRadius = Statics.MaxLightRadius;

		super.update(elapsed);
		FmodManager.Update();

		FlxG.collide(currentLevel.navigationLayer, player);

		moneyText.text = "" + Player.state.money;
		playerHealthText.text = "" + player.health;
		currentLevelText.text = "";

		if (FlxG.keys.pressed.O && FlxG.keys.justPressed.P && !Statics.moneyCheatUsed) {
			Statics.moneyCheatUsed = true;
			Player.state.money = 125;
		}

		FlxG.overlap(interactables, hitboxInteracts, interactWithItem);
		FlxG.overlap(interactables, hitboxTextInteracts, renderDialog);

		worldGroup.sort(SortingHelpers.SortByY, FlxSort.ASCENDING);
	}

	private function renderDialog(interactable:Interactable, hitboxTextInteract:HitboxTextInteract) {

		var currentDialogId = dialogManager.getCurrentDialogId();

		// Only render the shop text dialog if there is nothing else going on and the player is browsing for what to buy
		if ((currentDialogId != Dialogs.MatterConverterDescription &&
			currentDialogId != Dialogs.ShovelDescription &&
			currentDialogId != Dialogs.AxeDescription &&
			currentDialogId != Dialogs.HeartJarDescription &&
			currentDialogId != Dialogs.SpeedClogDescription &&
			currentDialogId != Dialogs.LedDescription)
				&& !dialogManager.isDone()) {
				return;
		}

		var dialogId = "";
		switch(interactable.name){
			case "Matter Converter":
				dialogId = Dialogs.MatterConverterDescription;
			case "Heart Jar":
				dialogId = Dialogs.HeartJarDescription;
			case "SpeedClog":
				dialogId = Dialogs.SpeedClogDescription;
			case "Pickaxe":
				dialogId = Dialogs.AxeDescription;
			case "Shovel":
				dialogId = Dialogs.ShovelDescription;
			case "LED Bulb":
				dialogId = Dialogs.LedDescription;
			default:
		}

		if (dialogId != "") {
			loadDialogIfPossible(dialogId);
		}
	}

	private function loadDialogIfPossible(dialogId:String) {
		if (dialogManager.getCurrentDialogId() != dialogId || dialogManager.isDone()) {
			dialogManager.loadDialog(dialogId);
		}
	}

	private function interactWithItem(interactable:Interactable, hitbox:Hitbox) {
		if (!interactable.hasBeenHitByThisHitbox(hitbox)) {
			FmodManager.StopSoundImmediately("attack");
			player.stopAttack();
			if (interactable.name == "Rope") {
				if (!player.hasUpgrade("Shovel")) {
					TextPop.pop(Std.int(200), Std.int(140), "You aren't ready", new SlowFadeUp(FlxColor.RED), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
					if (dialogManager.isDone()){
						dialogManager.loadDialog(Dialogs.ShovelRequired);
					}
				} else if (!isTransitioningStates){
					isTransitioningStates = true;
					// dialogManager.stopSounds();
					player.animation.play("climb_down");
					camera.fade(FlxColor.BLACK, 2, false, null, true);
					uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
					Statics.CurrentLevel = 1;
					Statics.CurrentSet = 1;
					Statics.GoingDown = true;
					Statics.CurrentLightRadius = Statics.MaxLightRadius;
					FmodFlxUtilities.TransitionToStateAndStopMusic(new PlayState());
					player.setPosition(interactable.x+4, interactable.y+4);
				}
			} else {
				if (interactable.name != "Shovel" && !player.hasUpgrade("Shovel")) {
					TextPop.pop(Std.int(player.x), Std.int(player.y), "Not the shovel", new SlowFade(FlxColor.RED), 10);
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
				} else {
					if (Player.state.money >= interactable.cost){
						Player.state.money -= interactable.cost;
						interactable.onInteract(player);
						TextPop.pop(Std.int(FlxG.width-47), Std.int(FlxG.height-35), "-$"+interactable.cost, new SlowFadeUp(FlxColor.RED), 10);
						FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchase);

						var shovelBoughtIndex = 2;
						var matterConverterBoughtIndex = 9;
						var heartJarIndex = 10;
						var speedClogIndex = 11;
						var axeIndex = 12;
						var ledIndex = 16;

						if (interactable.name == "Shovel") {
							dialogManager.loadDialog(Dialogs.ShovelPurchased);
						} else if (interactable.name == "Matter Converter") {
							dialogManager.loadDialog(Dialogs.MatterConverterPurchased);
						}  else if (interactable.name == "Heart Jar") {
							dialogManager.loadDialog(Dialogs.HeartJarPurchased);
						}  else if (interactable.name == "SpeedClog") {
							dialogManager.loadDialog(Dialogs.SpeedClogPurchased);
						}  else if (interactable.name == "Pickaxe") {
							dialogManager.loadDialog(Dialogs.AxePurchased);
						} else if (interactable.name == "LED Bulb") {
							dialogManager.loadDialog(Dialogs.LedPurchased);
						}
					} else {
						TextPop.pop(Std.int(player.x), Std.int(player.y), "Not enough money", new SlowFade(FlxColor.RED), 10);
						FmodManager.PlaySoundOneShot(FmodSFX.PlayerPurchaseFail);
					}
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