package states;

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

class PlayState extends FlxState
{
	var player:Player;
	var hitboxes:FlxTypedGroup<Hitbox> = new FlxTypedGroup<Hitbox>();
	var loots:FlxTypedGroup<Loot> = new FlxTypedGroup<Loot>();
	var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();

	public var currentLevel:Level;

	var moneyText:FlxText;
	var money:Int = 0;
	var playerHealthText:FlxText;

	var shader:Lighten;
	var lightFilter:ShaderFilter;

	var uiCamera:FlxCamera;

	var worldGroup:FlxGroup = new FlxGroup();

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

		camera.pixelPerfectRender = true;

		setupLightShader();

		FmodManager.PlaySong(FmodSongs.Cave);

		currentLevel = new Level();
		add(currentLevel.debugLayer);
		add(currentLevel.navigationLayer);
		add(currentLevel.interactableLayer);

		var exitTiles = currentLevel.interactableLayer.getTileCoords(3, false);
		levelExit = new Rope(exitTiles[0], new FlxPoint(16,16));
		add(levelExit);

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		worldGroup.add(player);


		var enemy1 = new entities.Rat(this, player, new FlxPoint(250, 30));
		enemy1.setNavigation(currentLevel, player);
		enemies.add(enemy1);
		worldGroup.add(enemy1);
		var enemy2 = new entities.Snake(this, player, new FlxPoint(100, 50));
		enemy2.setNavigation(currentLevel, player);
		enemies.add(enemy2);
		worldGroup.add(enemy2);
		// var enemy3 = new Enemy(this, player, new FlxPoint(FlxG.width-30, FlxG.height-30));
		// enemies.add(enemy3);
		// worldGroup.add(enemy3);

		moneyText = new FlxText(1, 1, 1000, "Money: ", 10);
		moneyText.cameras = [uiCamera];
		add(moneyText);
		playerHealthText = new FlxText(1, 15, 1000, "Health: ", 10);
		playerHealthText.cameras = [uiCamera];
		add(playerHealthText);

		add(worldGroup);
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

	public function addHitbox(hitbox:Hitbox) {
		hitboxes.add(hitbox);
		add(hitbox);
	}

	public function addLoot(loot:Loot) {
		loots.add(loot);
		worldGroup.add(loot);
	}

	public function IncreaseMoney(_money:Int) {
		money += _money;
	}

	private function playerExitTouch(p:Player, r:Rope) {
		FmodFlxUtilities.TransitionToState(new OutsideTheMinesState());
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

		shader.iTime.value[0] += elapsed;
		shader.lightSourceX.value[0] = player.getMidpoint().x;
		shader.lightSourceY.value[0] = player.getMidpoint().y;

		if(FlxG.keys.justPressed.P) {
			shader.isShaderActive.value[0] = !shader.isShaderActive.value[0];
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
		FlxG.overlap(player, loots, playerLootTouch);

		worldGroup.sort(sortByY, FlxSort.ASCENDING);
	}

	private function sortByY(Order:Int, basic1:FlxBasic, basic2:FlxBasic):Int {
		var result:Int = 0;

		var obj1:FlxObject = cast (basic1, FlxObject);
		var obj2:FlxObject = cast (basic2, FlxObject);
		if (obj1.y < obj2.y)
		{
			result = Order;
		}
		else if (obj1.y > obj2.y)
		{
			result = -Order;
		}

		return result;
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

	public function determineKnockbackDirectionForPlayer(_player:Player, _enemy:Enemy):FlxPoint {
        var direction = new FlxPoint(player.getMidpoint().x-_enemy.getMidpoint().x, _enemy.getMidpoint().y-player.getMidpoint().y);
        var directionNormalized = MathHelpers.NormalizeVector(direction);
        return directionNormalized;
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
