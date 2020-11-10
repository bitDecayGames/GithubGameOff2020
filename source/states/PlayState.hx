package states;

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

	override public function create()
	{
		super.create();

		FmodManager.PlaySong(FmodSongs.LetsGo);

		player = new Player(this);
		add(player);

		var enemy1 = new Enemy(this, player, new FlxPoint(30, 30));
		enemies.push(enemy1);
		add(enemy1);
		var enemy2 = new Enemy(this, player, new FlxPoint(FlxG.width-30, 30));
		enemies.push(enemy2);
		add(enemy2);
		var enemy3 = new Enemy(this, player, new FlxPoint(FlxG.width-30, FlxG.height-30));
		enemies.push(enemy3);
		add(enemy3);
	}

	public function addHitbox(hitbox:Hitbox) {
		hitboxes.push(hitbox);
		add(hitbox);
	}

	public function addLoot(loot:Loot) {
		loots.push(loot);
		add(loot);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (enemy in enemies) {
			for (hitbox in hitboxes) {
				if (FlxG.overlap(enemy, hitbox)) {
					if (!enemy.hasBeenHitByThisHitbox(hitbox)){
						FmodManager.PlaySoundOneShot(FmodSFX.ShovelEnemyImpact);
						enemy.applyDamage(1);
						enemy.setKnockback(determineKnockbackDirection(player.facing), 100, .5);
						enemy.trackHitbox(hitbox);
					}
				}
			}
		} 

		for (loot in loots) {
			if (FlxG.overlap(player, loot)) {
				loot.destroy();
				FmodManager.PlaySoundOneShot(FmodSFX.CollectCoin);
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
}
