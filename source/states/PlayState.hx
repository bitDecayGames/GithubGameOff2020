package states;

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

	var moneyText:FlxText;
	var money:Int = 0;
	var playerHealthText:FlxText;

	var shader:Lighten;
	var lightFilter:ShaderFilter;

	// uiCamera to keep stuff locked to screen positions
	var uiCamera:FlxCamera;

	var levelExit:FlxSprite;

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
		uiGroup.cameras = [uiCamera];
		add(uiGroup);

		camera.pixelPerfectRender = true;

		setupLightShader();

		FmodManager.PlaySong(FmodSongs.Cave);

		camera.fade(FlxColor.BLACK, 1.5, true);
		uiCamera.fade(FlxColor.BLACK, 1.5, true);

		currentLevel = new Level(AssetPaths.test__json);
		// add(currentLevel.debugLayer);
		add(currentLevel.groundLayer);
		add(currentLevel.navigationLayer);
		currentLevel.interactableLayer.alpha = 0;
		add(currentLevel.interactableLayer);

		var exitTiles = currentLevel.interactableLayer.getTileCoords(4, false);
		levelExit = new Rope(exitTiles[0], new FlxPoint(16,16));
		add(levelExit);

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));

		// var shovelUpgrade = new upgrades.Shovel();
		// player.addUpgrade(shovelUpgrade);
		// uiGroup.add(shovelUpgrade);

		worldGroup.add(player);


		var enemy1 = new entities.enemies.Rat(this, player, new FlxPoint(250, 30));
		enemies.add(enemy1);
		worldGroup.add(enemy1);
		var enemy2 = new entities.enemies.Snake(this, player, new FlxPoint(100, 50));
		enemies.add(enemy2);
		worldGroup.add(enemy2);
		var enemy3 = new entities.enemies.Bat(this, player, new FlxPoint(100, 100));
		enemies.add(enemy3);
		worldGroup.add(enemy3);
		var enemy4 = new entities.enemies.Blob(this, player, new FlxPoint(100, 100));
		enemies.add(enemy4);
		worldGroup.add(enemy4);

		moneyText = new FlxText(1, 1, 1000, "Money: ", 10);
		uiGroup.add(moneyText);

		playerHealthText = new FlxText(1, 15, 1000, "Health: ", 10);
		uiGroup.add(playerHealthText);

		add(worldGroup);

		// Timer.delay(() -> {
		// 	trace("adding mod");
		// 	var speedClog = new upgrades.SpeedClog();
		// 	uiGroup.add(speedClog);
		// 	player.addUpgrade(speedClog);
		// }, 5000);
	}

	private function setupLightShader() {
		shader = new Lighten();
		shader.iTime.value = [0];
		shader.lightSourceX.value = [0];
		shader.lightSourceY.value = [0];
		shader.lightRadius.value = [100];
		shader.isShaderActive.value = [true];
		lightFilter = new ShaderFilter(shader);
		camera.setFilters([lightFilter]);
	}

	public function IncreaseMoney(_money:Int) {
		money += _money;
	}

	private function playerExitTouch(p:Player, r:Rope) {
		if (!isTransitioningStates){
			isTransitioningStates = true;
			camera.fade(FlxColor.BLACK, 2, false, null, true);
			uiCamera.fade(FlxColor.BLACK, 2, false, null, true);
			FmodFlxUtilities.TransitionToStateAndStopMusic(new OutsideTheMinesState(OutsideTheMinesState.SkipIntro));
		}
	}

	private function enemyHitboxTouch(enemy:Enemy, hitbox:Hitbox) {
		if (!enemy.hasBeenHitByThisHitbox(hitbox)){
			FmodManager.PlaySoundOneShot(FmodSFX.ShovelEnemyImpact);
			enemy.applyDamage(1);
			enemy.setKnockback(determineKnockbackDirection(player.facing), 100, .5);
			enemy.trackHitbox(hitbox);
		}
	}

	private function playerEnemyTouch(player:Player, enemy:Enemy) {
		if (player.invincibilityTimeLeft <= 0){
			FmodManager.PlaySoundOneShot(FmodSFX.PlayerTakeDamage);
			player.applyDamage(1);
			player.setKnockback(determineKnockbackDirectionForPlayer(player, enemy), 100, .25);
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
		loot.path.cancel();
		loot.color = FlxColor.BLUE;
		loot.scale.set(5,5);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		FmodManager.Update();

		shader.iTime.value[0] += elapsed;
		shader.lightSourceX.value[0] = player.getMidpoint().x;
		shader.lightSourceY.value[0] = player.getMidpoint().y;

		if(FlxG.keys.justPressed.P) {
			shader.isShaderActive.value[0] = !shader.isShaderActive.value[0];
		}

		if(FlxG.keys.justPressed.N) {
			FmodFlxUtilities.TransitionToState(new OutsideTheMinesState(OutsideTheMinesState.SkipIntro));
		}

		if(FlxG.keys.justPressed.G) {
			if (player.alive) {
				player.kill();
			} else {
				player.revive();
			}
		}

		if(FlxG.keys.justPressed.R) {
			FmodFlxUtilities.TransitionToState(new PlayState());
		}
		if(FlxG.keys.justPressed.T) {
			var loot = new Loot(player.x+50, player.y);
			addLoot(loot);
		}

		moneyText.text = "Money: " + money;
		playerHealthText.text = "Health: " + player.health;

		FlxG.watch.addQuick("enemies: ", enemies.length);

		FlxG.collide(currentLevel.navigationLayer, player);
		FlxG.collide(currentLevel.navigationLayer, enemies);
		// TODO: For some reason colliding things on paths with the level doesn't work
		FlxG.collide(currentLevel.navigationLayer, loots, levelLootTouch);
		FlxG.collide(player, levelExit, playerExitTouch);
		FlxG.overlap(enemies, hitboxes, enemyHitboxTouch);
		FlxG.overlap(player, enemies, playerEnemyTouch);
		FlxG.overlap(player, projectiles, playerProjectileTouch);
		FlxG.overlap(player, loots, playerLootTouch);

		worldGroup.sort(SortingHelpers.SortByY, FlxSort.ASCENDING);
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
