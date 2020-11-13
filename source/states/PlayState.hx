package states;

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

class PlayState extends FlxState
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

	override public function create()
	{
		super.create();

		#if debug
		FlxG.debugger.drawDebug = true;
		#end

		camera.pixelPerfectRender = true;

		setupLightShader();

		FmodManager.PlaySong(FmodSongs.Cave);

		currentLevel = new Level();
		add(currentLevel.debugLayer);
		add(currentLevel.navigationLayer);

		player = new Player(this, new FlxPoint(FlxG.width/2, FlxG.height/2));
		add(player);

		var enemy1 = new entities.Rat(this, player, new FlxPoint(100, 30));
		enemy1.setNavigation(currentLevel, player);
		enemies.push(enemy1);
		add(enemy1);
		// var enemy2 = new Enemy(this, player, new FlxPoint(FlxG.width-30, 30));
		// enemies.push(enemy2);
		// add(enemy2);
		// var enemy3 = new Enemy(this, player, new FlxPoint(FlxG.width-30, FlxG.height-30));
		// enemies.push(enemy3);
		// add(enemy3);

		moneyText = new FlxText(1, 1, 1000, "Money: ", 10);
		add(moneyText);
		playerHealthText = new FlxText(1, 15, 1000, "Health: ", 10);
		add(playerHealthText);
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
		hitboxes.push(hitbox);
		add(hitbox);
	}

	public function addLoot(loot:Loot) {
		loots.push(loot);
		add(loot);
	}

	public function IncreaseMoney(_money:Int) {
		money += _money;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		shader.iTime.value[0] += elapsed;
		shader.lightSourceX.value[0] = player.getMidpoint().x;
		shader.lightSourceY.value[0] = player.getMidpoint().y;

		if(FlxG.keys.justPressed.P) {
			shader.isShaderActive.value[0] = !shader.isShaderActive.value[0];
		}
		if(FlxG.keys.justPressed.R) {
			FmodFlxUtilities.TransitionToState(new PlayState());
		}


		moneyText.text = "Money: " + money;
		playerHealthText.text = "Health: " + player.health;

		FlxG.watch.addQuick("enemies: ", enemies.length);

		for (enemy in enemies) {
			for (hitbox in hitboxes) {
				if (FlxG.overlap(enemy, hitbox)) {
					trace("RAT GOT TOUCHED");
					if (!enemy.hasBeenHitByThisHitbox(hitbox)){
						trace("RAT GOT SMAK");
						FmodManager.PlaySoundOneShot(FmodSFX.ShovelEnemyImpact);
						enemy.applyDamage(1);
						enemy.setKnockback(determineKnockbackDirection(player.facing), 100, .5);
						enemy.trackHitbox(hitbox);
					}
				}
			}

			if (FlxG.overlap(player, enemy)) {
				if (player.invincibilityTimeLeft <= 0){
					FmodManager.PlaySoundOneShot(FmodSFX.PlayerTakeDamage);
					player.applyDamage(1);
					player.setKnockback(determineKnockbackDirectionForPlayer(player, enemy), 100, .25);
				}
			}
		}

		for (loot in loots) {
			if (FlxG.overlap(player, loot)) {
				loot.destroy();
				FmodManager.PlaySoundOneShot(FmodSFX.CollectCoin);
				IncreaseMoney(1);
			}
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
