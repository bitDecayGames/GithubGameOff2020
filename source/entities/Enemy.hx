package entities;

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

class Enemy extends Entity {

    var player:FlxSprite;
    var collidedHitboxes:Map<Hitbox, Bool> = new Map<Hitbox, Bool>();
    var directionVector:FlxVector;

	public function new(_parentState:PlayState, _player:FlxSprite, position:FlxPoint) {
        super();
        healthPoints = 3;
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
        kill();
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
            directionVector = MathHelpers.NormalizeVector(direction);
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
        // Adding 4 to the y value to make the enemy aim lower
        var direction = new FlxPoint(player.getMidpoint().x-getMidpoint().x, player.getMidpoint().y+4-getMidpoint().y);
        var directionNormalized = MathHelpers.NormalizeVector(direction);
        return directionNormalized;
    }

    function dropLoot() {
        for (i in 0...2){
            var loot = new Loot(getMidpoint().x, getMidpoint().y);
            parentState.addLoot(loot);
        }
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
