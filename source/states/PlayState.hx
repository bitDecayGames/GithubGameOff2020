package states;

import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import flixel.tweens.FlxTween;
import entities.HitboxInteract;
import flixel.addons.display.FlxTiledSprite;
import entities.RopeUp;
import interactables.Interactable;
import entities.enemies.Blob;
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
import entities.loots.GoldCoin;
import level.Level;
import flixel.text.FlxText;
import entities.Loot;
import helpers.MathHelpers;
import helpers.SortingHelpers;
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

class PlayState extends BaseState
{
	var player:Player;

	var shader:Lighten;
	var lightFilter:ShaderFilter;
	var flickerCounter:Int;

	// uiCamera to keep stuff locked to screen positions
	var uiCamera:FlxCamera;

	var crystalKnockbackGracePeriod:Bool;

	var levelExitUp:Interactable;
	var levelExitDown:Interactable;

	var crystalReference:Enemy;
	var crystalSound:String;

	private static var levelOrder = [
		AssetPaths.outsideTheMines__json,
		AssetPaths.caves1__json,
		AssetPaths.caves2__json,
		AssetPaths.caves3__json,
		AssetPaths.caves4__json,
		AssetPaths.caves5__json,
		AssetPaths.caves6__json,
		AssetPaths.caves7__json,
		AssetPaths.caves8__json,
		AssetPaths.caves9__json,
		AssetPaths.caves10__json,
		AssetPaths.caves11__json,
	];

	private static var MAX_MONEY_ATTAINED = 0;

	override public function create()
	{
		super.create();
		#if debug
		FlxG.debugger.drawDebug = true;
		#end

		FlxCamera.defaultCameras = [FlxG.camera];

		uiCamera = new FlxCamera(0, 0, 320, 272);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		uiGroup.cameras = [uiCamera];
		add(uiGroup);

		setupHUD();

		camera.pixelPerfectRender = true;

		setupLightShader();

		if (Statics.CurrentLevel == levelOrder.length-1) {
			FmodManager.PlaySong(FmodSongs.CrystalArea);
			crystalSound = FmodManager.PlaySoundAndAssignId(FmodSFX.CrystalNear, "Crystal");
		} else {
			FmodManager.PlaySong(FmodSongs.Cave);
		}

		camera.fade(FlxColor.BLACK, 1.5, true);
		uiCamera.fade(FlxColor.BLACK, 1.5, true);

		currentLevel = new Level(levelOrder[Statics.CurrentLevel], Statics.CurrentLevel);
		// add(currentLevel.debugLayer);
		add(currentLevel.groundLayer);
		add(currentLevel.navigationLayer);
		currentLevel.interactableLayer.alpha = 0;
		add(currentLevel.interactableLayer);
		add(currentLevel.foregroundLayer);

		levelExitDown = currentLevel.downRope;
		addInteractable(levelExitDown);
		// This makes us collide with the tile that the downrope is at
		currentLevel.navigationLayer.setTile(Std.int(levelExitDown.x / 16), Std.int(levelExitDown.y / 16), 1);

		setupEscapeRope(currentLevel.upRope);

		if (Statics.GoingDown) {
			player = new Player(this, new FlxPoint(levelExitUp.x, levelExitUp.y+16));
		} else {
			player = new Player(this, new FlxPoint(levelExitDown.x, levelExitDown.y+16));
		}

		if (Statics.matterConverterConsuming) {
			// in case the player left a level while their light was recharging
			Statics.CurrentLightRadius = Statics.MaxLightRadius;
		}

		worldGroup.add(player);

		for (enemyMaker in currentLevel.enemyMakers) {
			var enemy = enemyMaker(this, player);
			enemies.add(enemy);
			worldGroup.add(enemy);

			if (enemy.enemyName == "Crystal") {
				crystalReference = enemy;
			}
		}

		add(worldGroup);
	}

	private function setupEscapeRope(levelUpRope:RopeUp) {
		levelExitUp = levelUpRope;
		var restOfRope  = new FlxTiledSprite(AssetPaths.escapeRope__png, 16, levelExitUp.y, false, true);
		restOfRope.setPosition(levelExitUp.x, 0);
		// restOfRope.alpha = 0.2;
		addInteractable(levelExitUp);
		// a bit of a hack to make sure this renders on top of everything
		worldGroup.add(restOfRope);
	}

	private function setupLightShader() {
		shader = new Lighten();
		shader.iTime.value = [0];
		shader.lightSourceX.value = [0];
		shader.lightSourceY.value = [0];
		shader.isShaderActive.value = [true];
		lightFilter = new ShaderFilter(shader);
		camera.setFilters([lightFilter]);
	}

	public function IncreaseMoney(_money:Int) {
		Player.state.money += _money;

		if (Player.state.money > MAX_MONEY_ATTAINED) {
			MAX_MONEY_ATTAINED = Player.state.money;
			Bitlytics.Instance().Queue(Metrics.MAX_MONEY, MAX_MONEY_ATTAINED);
		}
	}

	private function enemyHitboxTouch(enemy:Enemy, hitbox:Hitbox) {
		if (!enemy.hasBeenHitByThisHitbox(hitbox)){
			if (!enemy.dead){
				if (enemy.enemyName == "Crystal") {
					if (player.hasUpgrade("Pickaxe")) {
						// DAMAGE THE CRUSTAL
						FmodManager.PlaySoundOneShot(FmodSFX.CrystalHitPickaxe);
						FlxG.camera.shake(0.005, 0.25);
						enemy.applyDamage(1);
					} else {
						FmodManager.PlaySoundOneShot(FmodSFX.CrystalHitShovel);
					}
				} else {
					if (!player.hasUpgrade("Pickaxe")){
						FmodManager.PlaySoundOneShot(FmodSFX.ShovelEnemyImpact);
					} else {
						FmodManager.PlaySoundOneShot(FmodSFX.ShovelEnemyImpactHigherBass);
					}
					enemy.setKnockback(determineKnockbackDirection(player.facing), 100, .25);

					if (player.hasUpgrade("Pickaxe")) {
						enemy.applyDamage(3);
						FlxG.camera.shake(0.01, 0.05);
					} else {
						enemy.applyDamage(1);
					}
				}
			}
			enemy.trackHitbox(hitbox);
		}
	}

	private function playerEnemyTouch(player:Player, enemy:Enemy) {
		if (!enemy.dead){
			if (enemy.enemyName == "Crystal" && !crystalKnockbackGracePeriod) {
				crystalKnockbackGracePeriod = true;
				Timer.delay(() -> {
					crystalKnockbackGracePeriod = false;
				}, 500);
				FmodManager.PlaySoundOneShot(FmodSFX.PlayerTakeDamage);
				player.setKnockback(FlxPoint.get(1, 0), 100, .5);
			} else {
				if (player.invincibilityTimeLeft <= 0){
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerTakeDamage);
					player.applyDamage(1);
					player.setKnockback(determineKnockbackDirectionForPlayer(player, enemy), 100, .25);
				}
			}
		}
	}

	private function playerProjectileTouch(player:Player, proj:FlxSprite) {
		if (player.invincibilityTimeLeft <= 0){
			FmodManager.PlaySoundOneShot(FmodSFX.PlayerTakeDamage);
			player.applyDamage(1);
			player.setKnockback(determineKnockbackDirectionForPlayer(player, proj), 100, .25);
			proj.kill();
		}
	}

	private function playerLootTouch(player:Player, loot:Loot) {
		FmodManager.PlaySoundOneShot(FmodSFX.CollectCoin);
		IncreaseMoney(loot.coinValue);
		TextPop.pop(Std.int(player.x), Std.int(player.y), "$"+loot.coinValue, new SlowFade(), 7);
		loot.destroy();
	}

	private function levelLootTouch(tilemap:FlxTilemap, loot:Loot) {
		// TODO: The goal here is to have the loot stay on the map.
		// However, collisions don't seem to behave properly.
		// This function will make it obvious when things START working
		// loot.path.cancel();
		// loot.color = FlxColor.BLUE;
		// loot.scale.set(5,5);
	}

	public function playerHasDied() {
		Timer.delay(() -> {
			camera.fade(FlxColor.BLACK, 2, false, null, true);
			uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
			Statics.CurrentLevel = 0;
			Statics.CurrentSet = 1;
			FmodFlxUtilities.TransitionToStateAndStopMusic(new OutsideTheMinesState(OutsideTheMinesState.SkipIntro));
		}, 3000);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		FmodManager.Update();

		if (crystalReference != null && Statics.CurrentLevel == levelOrder.length-1) {
			var CrystalVolumeRadius = 200;
			var distanceFromCrystal = player.getPosition().distanceTo(crystalReference.getPosition());
			distanceFromCrystal -= 50;
			distanceFromCrystal = Math.max(distanceFromCrystal, 0);
			trace("distance from crystal: " + distanceFromCrystal);
			var crystalVolume = Math.max(0, 1-(distanceFromCrystal/CrystalVolumeRadius));
			FmodManager.SetEventParameterOnSound(crystalSound, "CrystalVolume", crystalVolume);
		}

		shader.iTime.value[0] += elapsed;
		shader.lightSourceX.value[0] = player.getMidpoint().x + player.lightOffset.x;
		shader.lightSourceY.value[0] = player.getMidpoint().y + player.lightOffset.y;
		shader.lightRadius.value = [Statics.CurrentLightRadius];

		if (FlxG.keys.pressed.L) {
			trace(Statics.CurrentLightRadius);
			trace("   " + (Statics.minLightRadius + 2));
		}
		if (Statics.CurrentLightRadius < (Statics.minLightRadius + 2) && !player.isDead){
			if (flickerCounter == 0){
				FmodManager.PlaySoundOneShot(FmodSFX.LightFlickering);
			}
			if (flickerCounter <= 8){
				shader.lightRadius.value[0] = 0;
			}
			flickerCounter = (flickerCounter+1) % 10;
		}

		moneyText.text = "" + Player.state.money;
		playerHealthText.text = "" + player.health;
		var levelNumber = Statics.CurrentLevel;
		currentLevelText.text = "";
		if (levelNumber > 0) {
			currentLevelText.text += levelNumber;
		}

		FlxG.watch.addQuick("enemies: ", enemies.length);

		FlxG.collide(currentLevel.navigationLayer, enemies);
		FlxG.collide(currentLevel.navigationLayer, loots, levelLootTouch);

		if (!isTransitioningStates) {
			FlxG.collide(currentLevel.navigationLayer, player);
			// TODO: For some reason colliding things on paths with the level doesn't work
			FlxG.overlap(enemies, hitboxes, enemyHitboxTouch);
			FlxG.overlap(player, enemies, playerEnemyTouch);
			FlxG.overlap(player, projectiles, playerProjectileTouch);
			FlxG.overlap(player, loots, playerLootTouch);
			FlxG.overlap(interactables, hitboxInteracts, interactWithItem);
			FlxG.overlap(hitboxInteracts, enemies, interactWithDeadEnemy);
		}

		worldGroup.sort(SortingHelpers.SortByY, FlxSort.ASCENDING);
	}

	private function interactWithDeadEnemy(hitboxInteract:HitboxInteract, enemy:Enemy) {
		if (enemy.dead && player.hasUpgrade("Matter Converter") && !Statics.matterConverterConsuming){
			enemy.kill();
			if (enemy.enemyName == "Crystal") {
				return;
			}
			player.stopAttack();
			enemy.cacheEntry.consumed = true;
			Statics.MatterConverterCharges += 1;
			FmodManager.PlaySoundOneShot(FmodSFX.Pop);
			Timer.delay(() -> {
				if (Statics.MatterConverterCharges == 1) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge1);
				}
				else if (Statics.MatterConverterCharges == 2) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge2);
				}
				else if (Statics.MatterConverterCharges == 3) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge3);
				}
				else if (Statics.MatterConverterCharges == 4) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge4);
				}
				else if (Statics.MatterConverterCharges == 5) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge5);
				}
				else if (Statics.MatterConverterCharges >= 6) {
					FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterNewCharge6);
					Statics.matterConverterConsuming = true;
					Statics.MatterConverterCharges = 0;
					Timer.delay(() -> {
						FmodManager.PlaySoundOneShot(FmodSFX.MatterConverterGears);
						Timer.delay(() -> {
							FmodManager.PlaySoundOneShot(FmodSFX.LightRechargeNoClick);
							Timer.delay(() -> {
								FlxTween.num(Statics.CurrentLightRadius, Statics.MaxLightRadius, 2, {}, function(v)
									{
										Statics.CurrentLightRadius = v;
									});
								Timer.delay(() -> {
									Statics.matterConverterConsuming = false;
								}, 4000);
							}, 1000);
						}, 2000);
					}, 750);
				}
			}, 400);
		}
	}

	private function interactWithItem(interactable:Interactable, hitbox:Hitbox) {
		if (!interactable.hasBeenHitByThisHitbox(hitbox)) {
			if (interactable.name == "Rope") {
				if (!isTransitioningStates){
					isTransitioningStates = true;
					player.stopAttack();
					player.animation.play("climb_down");
					camera.fade(FlxColor.BLACK, 2, false, null, true);
					uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
					Statics.GoingDown = true;
					Timer.delay(() -> {
						Statics.IncrementLevel();
						if (Statics.CurrentLevel == levelOrder.length-1) {
							FmodFlxUtilities.TransitionToStateAndStopMusic(new PlayState());
						} else if (Statics.CurrentLevel >= levelOrder.length) {
							FmodFlxUtilities.TransitionToState(new CreditsState());
						} else {
							FmodFlxUtilities.TransitionToState(new PlayState());
						}
					}, 1500);
					player.setPosition(interactable.x+4, interactable.y+4);
				}
			}
			if (interactable.name == "RopeUp") {
				if (!isTransitioningStates){
					isTransitioningStates = true;
					player.stopAttack();
					player.facing = FlxObject.RIGHT;
					player.animation.play("climb_up");
					player.climbRope();
					camera.fade(FlxColor.BLACK, 2, false, null, true);
					uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
					Statics.GoingDown = false;
					if (Statics.CurrentLevel > 1){
						Timer.delay(() -> {
							Statics.DecrementLevel();
							FmodFlxUtilities.TransitionToState(new PlayState());
						}, 1500);
					} else {
						Statics.DecrementLevel();
						FmodFlxUtilities.TransitionToStateAndStopMusic(new OutsideTheMinesState(OutsideTheMinesState.SkipIntro));
					}
					player.setPosition(interactable.x+4, interactable.y+4);
					player.ID = SortingHelpers.SORT_TO_TOP;
				}
			}
			interactable.trackHitbox(hitbox);
		}
	}

	public function determineKnockbackDirection(playerFacing:Int):FlxPoint {
		var knockbackDirection:FlxPoint;
        switch playerFacing {
            case FlxObject.RIGHT:
                knockbackDirection =  new FlxPoint(1, 0);
            case FlxObject.DOWN:
				knockbackDirection =  new FlxPoint(0, -1);
            case FlxObject.LEFT:
                knockbackDirection = new FlxPoint(-1, 0);
            case FlxObject.UP:
                knockbackDirection =  new FlxPoint(0, 1);
			default:
				knockbackDirection =  new FlxPoint(1, 1);
		}
		return knockbackDirection;
	}

	public function determineKnockbackDirectionForPlayer(_player:Player, other:FlxSprite):FlxPoint {
        var direction = new FlxPoint(player.getMidpoint().x-other.getMidpoint().x, other.getMidpoint().y-player.getMidpoint().y);
        var directionNormalized = MathHelpers.NormalizeVector(direction);
        return directionNormalized;
	}
}
