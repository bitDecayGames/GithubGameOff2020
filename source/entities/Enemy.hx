package entities;

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

class Enemy extends Entity {

    var player:FlxSprite;
    var collidedHitboxes:Map<Hitbox, Bool> = new Map<Hitbox, Bool>();

	public function new(_parentState:PlayState, _player:FlxSprite, position:FlxPoint) {
        super();
        healthPoints = 5;
        player = _player;
        size = new FlxPoint(10, 10);
        speed = 10;
        direction = 0;
        parentState = _parentState;
        attacking = false;
        makeGraphic(Std.int(size.x), Std.int(size.y), FlxColor.BLUE);
        setPosition(position.x, position.y);
    }
    
    override public function destroy() {
        FmodManager.PlaySoundOneShot(FmodSFX.EnemyDeath);
        super.destroy();
    }

	override public function update(delta:Float):Void {
        super.update(delta);
        
        if (inKnockback){
            setPosition(x + knockbackDirection.x*delta*knockbackSpeed, y + knockbackDirection.y*delta*knockbackSpeed*-1);
            knockbackDuration -= delta;
            if (knockbackDuration <= 0) {
                inKnockback = false;
                if (healthPoints <= 0) {
                    dropLoot();
                    destroy();
                }
            }
        } else {
            var direction:FlxPoint = determineDirection(player);
            facing = determineFacing(direction);
            var directionVector = MathHelpers.NormalizeVector(direction);
            setPosition(x + directionVector.x*delta*speed, y + directionVector.y*delta*speed);
        }
    }

    public function hasBeenHitByThisHitbox(hitbox:Hitbox):Bool{
        return collidedHitboxes.get(hitbox);
    }

    public function trackHitbox(hitbox:Hitbox) {
        collidedHitboxes.set(hitbox, true);
    }

    public function applyDamage(_damage:Int) {
        healthPoints -= _damage;
    }

    public function setKnockback(_knockbackDirection:FlxPoint, _knockbackSpeed:Float, _knockbackDuration:Float) {
        inKnockback = true;
        knockbackDirection = _knockbackDirection;
        knockbackSpeed = _knockbackSpeed;
        knockbackDuration = _knockbackDuration;

        FlxFlicker.flicker(this, knockbackDuration);
    }

    function determineDirection(player:FlxSprite):FlxPoint {
        var direction = new FlxPoint(player.x-x, player.y-y);
        var directionNormalized = MathHelpers.NormalizeVector(direction);
        return directionNormalized;
    }

    function dropLoot() {
        for (i in 0...2){
            var loot = new Loot(getMidpoint().x, getMidpoint().y);
            parentState.addLoot(loot);
        }
    }

    function determineFacing(vector:FlxPoint):Int {
        if (vector.x > 0 && vector.y > 0) {
            if (facing == FlxObject.UP || facing == FlxObject.RIGHT){
                return facing;
            }
        } else if (vector.x > 0 && vector.y < 0) {
            if (facing == FlxObject.DOWN || facing == FlxObject.RIGHT){
                return facing;
            }
        } else if (vector.x < 0 && vector.y < 0) {
            if (facing == FlxObject.DOWN || facing == FlxObject.LEFT){
                return facing;
            }
        } else if (vector.x < 0 && vector.y > 0) {
            if (facing == FlxObject.UP || facing == FlxObject.LEFT){
                return facing;
            }
        }

        if (vector.x > 0){
            return FlxObject.RIGHT;
        } else if (vector.x < 0) {
            return FlxObject.LEFT;
        } else if (vector.y < 0) {
            return FlxObject.DOWN;
        } else if (vector.y > 0) {
            return FlxObject.UP;
        }

        return facing;
    }
}
