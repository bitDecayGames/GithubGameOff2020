package entities;

import level.EnemyCache;
import level.Level;
import flixel.math.FlxVector;
import flixel.math.FlxMath;
import flixel.util.FlxPath;
import flixel.effects.FlxFlicker;
import states.PlayState;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import haxe.Timer;
import flixel.util.FlxColor;
import haxefmod.FmodManager;
import helpers.MathHelpers;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;

class LootChance {
    public var chance:Float;
    public var count:Int;

    public function new (_chance:Float, _count:Int) {
        chance = _chance;
        count = _count;
    }
}

class LootTypeChance {
    public var chance:Float;
    public var type:Class<Loot>;
    public function new (_chance:Float, _type:Class<Loot>) {
        chance = _chance;
        type = _type;
    }
}

class Enemy extends Entity {

    var player:Player;
    var collidedHitboxes:Map<Hitbox, Bool> = new Map<Hitbox, Bool>();
    var directionVector:FlxVector;
    public var dead:Bool = false;

    var level:Level;
    public var cacheEntry:EnemyCache;

    var enemyName:String = "Unset";
    private var lootChances:Array<LootChance>;
    private var lootTypeChances:Array<LootTypeChance>;

    //Sounds
    var deathSound:String = FmodSFX.MenuSelect;

	public function new(_parentState:PlayState, _player:Player, position:FlxPoint, cache:EnemyCache, ?_deathSound:String = null) {
        super(_parentState);

        health = 3;
        player = _player;
        cacheEntry = cache;
        size = new FlxPoint(10, 10);
        deathSound = _deathSound;

        baseStats.speed = 10;
        refresh();

        direction = 0;
        attacking = false;
        makeGraphic(Std.int(size.x), Std.int(size.y), FlxColor.BLUE);
        setPosition(position.x, position.y);
    }

    override public function destroy() {
        kill();
    }

    public function playDeathSound() {
        if (deathSound != null){
            FmodManager.PlaySoundOneShot(deathSound);
        }
    }

	override public function update(delta:Float):Void {
        super.update(delta);

        // update our cache entry so that we respawn properly
        cacheEntry.position.set(x, y);

        if (health <= 0 && dead){
            animation.play("dead");
            ID = 998;
            if (enemyName == "Blob"){
                kill();
                cacheEntry.dead = true;
                cacheEntry.consumed = true;
            }
            return;
        }

        if (health <= -1) {
            // if the player hits enemies in knockback, they can be killed immediately
            cacheEntry.dead = true;
            cacheEntry.position = getPosition();
            dropLoot();
            animation.play("dead");
            dead = true;
            playDeathSound();
            return;
        }

        if (inKnockback){
            setPosition(x + knockbackDirection.x*delta*knockbackSpeed, y + knockbackDirection.y*delta*knockbackSpeed*-1);
            knockbackDuration -= delta;
            if (knockbackDuration <= 0) {
                inKnockback = false;
                if (health <= 0) {
                    cacheEntry.dead = true;
                    cacheEntry.position = getPosition();
                    dropLoot();
                    animation.play("dead");
                    dead = true;
                    playDeathSound();
                    return;
                }
            }
        } else {
            // var direction:FlxPoint = determineDirection(player);
            // facing = determineFacing(direction);
            // directionVector = MathHelpers.NormalizeVector(direction);
            // setPosition(x + directionVector.x*delta*speed, y + directionVector.y*delta*speed);
        }
    }

    public function hasBeenHitByThisHitbox(hitbox:Hitbox):Bool{
        return collidedHitboxes.get(hitbox);
    }

    public function trackHitbox(hitbox:Hitbox) {
        collidedHitboxes.set(hitbox, true);
    }

    public function applyDamage(_damage:Int) {
        health -= _damage;
    }

    public function setKnockback(_knockbackDirection:FlxPoint, _knockbackSpeed:Float, _knockbackDuration:Float) {
        inKnockback = true;
        knockbackDirection = _knockbackDirection;
        knockbackSpeed = _knockbackSpeed;
        knockbackDuration = _knockbackDuration;

        FlxFlicker.flicker(this, knockbackDuration);
    }

    function determineDirection(player:FlxSprite):FlxPoint {
        // Adding 4 to the y value to make the enemy aim lower
        var direction = new FlxPoint(player.getMidpoint().x-getMidpoint().x, player.getMidpoint().y+4-getMidpoint().y);
        var directionNormalized = MathHelpers.NormalizeVector(direction);
        return directionNormalized;
    }

    private function verifyLootChance():Bool {
        if (lootChances == null) {
            trace("Loot chance for " + enemyName + " not set!");
            return false;
        }

        var totalLootPercentage:Float = 0;
        for (lootChance in lootChances){
            totalLootPercentage += lootChance.chance;
        }

        if (totalLootPercentage != 1.0) {
            trace("Loot chance values for " + enemyName + " do not equal 100%. Total loot percentages added together should equal 1.0. Actual value: " + totalLootPercentage);
            return false;
        }


        
        if (lootTypeChances == null) {
            trace("Loot type chance for " + enemyName + " not set!");
            return false;
        }

        var totalLootTypePercentage:Float = 0;
        for (lootTypeChance in lootTypeChances){
            totalLootTypePercentage += lootTypeChance.chance;
        }

        if (totalLootTypePercentage != 1.0) {
            trace("Loot type chance values for " + enemyName + " do not equal 100%. Total loot type percentages added together should equal 1.0. Actual value: " + totalLootTypePercentage);
            return false;
        }

        return true;
    }

    function dropLoot() {
        if (!verifyLootChance()) {
            return;
        }

        var finalLootCount:Int = 0;

        var lootSeed = Math.random();
        for (lootChance in lootChances) {
            lootSeed -= lootChance.chance;
            if (lootSeed <= 0) {
                finalLootCount = lootChance.count;
                break;
            }
        }

        while (finalLootCount > 0){
            var loot = generateLoot(getMidpoint().x, getMidpoint().y);
            parentState.addLoot(loot);
            finalLootCount--;
        }
    }

    function generateLoot(_x:Float, _y:Float):Loot {
        var lootTypeSeed = Math.random();
        for (lootTypeChance in lootTypeChances) {
            lootTypeSeed -= lootTypeChance.chance;
            if (lootTypeSeed <= 0) {
                return Type.createInstance(lootTypeChance.type, [_x, _y]);
            }
        }
        trace("Unable to determine loot type");
        return null;
    }

    function determineFacing(vector:FlxVector):Int {
        // degrees here is CLOCKWISE, with straight-right being 0
        var angle = vector.degrees;
        while (angle < 0) {
            angle += 360;
        }
        while (angle >= 360) {
            angle -= 360;
        }
        if (angle < 45 || angle > 315) {
            return FlxObject.RIGHT;
        } else if (angle < 135) {
            return FlxObject.DOWN;
        } else if (angle < 235) {
            return FlxObject.LEFT;
        } else {
            return FlxObject.UP;
        }
    }
}
