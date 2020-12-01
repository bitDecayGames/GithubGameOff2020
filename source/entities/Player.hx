package entities;

import textpop.SlowFade;
import com.bitdecay.textpop.TextPop;
import states.OutsideTheMinesState;
import upgrades.Upgrade;
import states.BaseState;
import entities.Stats.StatModifier;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.effects.FlxFlicker;
import actions.Actions;
import states.PlayState;
import haxe.Timer;
import flixel.util.FlxColor;
import haxefmod.FmodManager;
import helpers.MathHelpers;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
using extensions.FlxObjectExt;

class Player extends Entity {

    public static var state = new GameState();

    public var isDead:Bool;

    var controls:Actions;
    var areControlsActive = true;
    public var canAttack = true;

    var stepFXPlayed:Bool = false;
    var movementRatio = new FlxPoint(1, 0.8);

    var playerHitboxOffsetX = 4;
    var playerHitboxOffsetY = 14;

    var climbingRope = false;

    public var lightOffset = FlxPoint.get(0, -11);

    public var invincibilityTimeLeft:Float = 0;

    public var shovel:FlxSprite;
    public var upgrades:Array<Upgrade> = new Array<Upgrade>();

    var hitboxTextInteract:HitboxTextInteract;

    var lastFrameLightRadius:Float;

	public function new(_parentState:BaseState, _spawnPosition:FlxPoint) {
        super(_parentState);
        controls = new Actions();

        baseStats = state.baseStats;
        for (upMkr in state.upgradeMakers) {
            var up = upMkr();
            upgrades.push(up);
            parentState.addUIElement(up);
            addModifier(up.modifier);
        }

        #if debug
        trace("player has " + upgrades.length + " upgrades on load");
        for (up in upgrades) {
            trace("   " + up.getDescription());
        }
        #end

        organizeUpgrades();

        health = Player.state.activeStats.currentHealth;

        size = new FlxPoint(16, 32);
        direction = 0;
        attacking = false;
        setPosition(_spawnPosition.x, _spawnPosition.y);

        super.loadGraphic(AssetPaths.Player__png, true, 16, 32);

        // Update hitbox to be smaller than sprite
        setSize(8, 10);
        offset.set(playerHitboxOffsetX, playerHitboxOffsetY);

        var animationSpeed:Int = 8;

        animation.add("walk_up", [19,20,21,22,23,24,25,26], animationSpeed);
        animation.add("walk_right", [10,11,12,13,14,15,16,17], animationSpeed);
        animation.add("walk_down", [1,2,3,4,5,6,7,8], animationSpeed);
        animation.add("walk_left", [10,11,12,13,14,15,16,17], animationSpeed);

        animation.add("stand_up", [18], animationSpeed);
        animation.add("stand_right", [9], animationSpeed);
        animation.add("stand_down", [0], animationSpeed);
        animation.add("stand_left", [9], animationSpeed);

        var attackAnimationSpeed:Int = 30;

        animation.add("swipe_down", [27,28,29,30,31,32,33,34], attackAnimationSpeed, false);
        animation.add("swipe_right", [36,37,38,39,40,41,42,43], attackAnimationSpeed, false);
        animation.add("swipe_up", [45,46,47,48,49,50,51,52], attackAnimationSpeed, false);
        animation.add("swipe_left", [36,37,38,39,40,41,42,43], attackAnimationSpeed, false);

        animation.add("faceplant", [54], animationSpeed);
        animation.add("faceplant_get_up", [55,56,57,58,59], animationSpeed, false);

        animation.add("climb_down", [59,58,57,56,55,60], animationSpeed, false);
        animation.add("climb_up", [64,65,66,67,68], animationSpeed);

        animation.play("stand_down");

        animation.callback = animCallback;
        animation.finishCallback = animationOnFinishCallback;

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.DOWN, false, false);
        setFacingFlip(FlxObject.UP, false, false);

        var textInteractionLocation:FlxPoint;
        var hitboxTextInteractSize = new FlxPoint(5, 5);
        switch facing {
            case FlxObject.RIGHT:
                textInteractionLocation = new FlxPoint(x+8, y);
            case FlxObject.DOWN:
                textInteractionLocation = new FlxPoint(x+2, y+10);
            case FlxObject.LEFT:
                textInteractionLocation = new FlxPoint(x-5, y);
            case FlxObject.UP:
                textInteractionLocation = new FlxPoint(x, y-10);
            default:
                textInteractionLocation = new FlxPoint(x, y);
        }
        hitboxTextInteract = new HitboxTextInteract(textInteractionLocation, hitboxTextInteractSize);
        parentState.addHitboxTextInteract(hitboxTextInteract);
    }

    public function animCallback(name:String, frameNumber:Int, frameIndex:Int):Void {
		if (!stepFXPlayed && StringTools.contains(name, "walk_") && frameNumber == 3 || frameNumber == 7) {
			FmodManager.PlaySoundOneShot(FmodSFX.FootstepRock);
            stepFXPlayed = true;
		} else {
            // reset this once a different frame happens
            stepFXPlayed = false;
        }
    }

    public function animationOnFinishCallback(name:String) {
        if (name == "faceplant_get_up") {
            areControlsActive = true;
            animation.play("stand_down");
            facing = FlxObject.DOWN;
        }
    }

    public function hasUpgrade(name:String){
        var hasUpgrade = false;
        for (upgrade in upgrades) {
            if (upgrade.name == name) {
                hasUpgrade = true;
                return true;
            }
        }
        return false;
    }

    public function setControlsActive(_areActive:Bool){
        areControlsActive = _areActive;
    }

    public function setCanAttack(_canAttack:Bool){
        canAttack = _canAttack;
    }

    public function climbRope() {
        climbingRope = true;
    }

	override public function update(delta:Float):Void {
        super.update(delta);

        Player.state.activeStats.currentHealth = health;

        var interactTextLocation:FlxPoint;
        switch facing {
            case FlxObject.RIGHT:
                interactTextLocation = new FlxPoint(x+8, y);
            case FlxObject.DOWN:
                interactTextLocation = new FlxPoint(x+2, y+10);
            case FlxObject.LEFT:
                interactTextLocation = new FlxPoint(x-5, y);
            case FlxObject.UP:
                interactTextLocation = new FlxPoint(x, y-10);
            default:
                interactTextLocation = new FlxPoint(x, y);
        }
        hitboxTextInteract.updatePostion(interactTextLocation);

		var halfDrained = (Statics.MaxLightRadius-Statics.minLightRadius)/2 + Statics.minLightRadius;
		if (Statics.CurrentLightRadius <= halfDrained && lastFrameLightRadius > halfDrained){
            TextPop.pop(Std.int(x-6), Std.int(y), "Battery", new SlowFade(FlxColor.YELLOW), 7);
            TextPop.pop(Std.int(x), Std.int(y+8), "50%", new SlowFade(FlxColor.YELLOW), 7);
            FmodManager.PlaySoundOneShot(FmodSFX.LightWarning50Percent);
        }

		var threeForthsDrained = (Statics.MaxLightRadius-Statics.minLightRadius)*.25 + Statics.minLightRadius;
		if (Statics.CurrentLightRadius <= threeForthsDrained && lastFrameLightRadius > threeForthsDrained){
            TextPop.pop(Std.int(x-6), Std.int(y), "Battery", new SlowFade(FlxColor.RED), 7);
            TextPop.pop(Std.int(x-7), Std.int(y+8), "Critical", new SlowFade(FlxColor.RED), 7);
            FmodManager.PlaySoundOneShot(FmodSFX.LightWarning25Percent);
        }

        // save this frame's light radius for use next frame
	    lastFrameLightRadius = Statics.CurrentLightRadius;
        if (!parentState.isTransitioningStates){
            Statics.CurrentLightRadius -= Statics.lightDrainRate * delta;
        }

        if (!isDead){
            Statics.CurrentLightRadius = Math.max(Statics.CurrentLightRadius, Statics.minLightRadius);
        }

        if (Statics.CurrentLightRadius <= Statics.minLightRadius && !isDead){
            isDead = true;
            active = false;
            alive = false;
            Statics.CurrentLightRadius = 0;
            FmodManager.PlaySoundOneShot(FmodSFX.LightGoingOut);
            Timer.delay(() -> {
                FmodManager.PlaySoundOneShot(FmodSFX.PlayerDeath);
                var playState = cast(parentState, PlayState);
                playState.playerHasDied();
                Statics.PlayerDiedDueToLight();
            }, 1000);
        }

        if (invincibilityTimeLeft > 0){
            invincibilityTimeLeft -= delta;
        }

        var potentialDirection:FlxPoint = new FlxPoint(0, 0);
		potentialDirection = readDirectionInput();

        if (climbingRope) {
            var climbUpSpeed = 50;
            setPosition(x, y + delta*climbUpSpeed*-1);
        } else if (inKnockback){
            setPosition(x + knockbackDirection.x*delta*knockbackSpeed, y + knockbackDirection.y*delta*knockbackSpeed*-1);
            knockbackDuration -= delta;
            if (knockbackDuration <= 0) {
                inKnockback = false;
                if (health <= 0) {
                    isDead = true;
                    ID = 998;
                    active = false;
                    FlxFlicker.stopFlickering(this);
                    var playState = cast(parentState, PlayState);
                    FmodManager.PlaySoundOneShot(FmodSFX.PlayerDeath);
                    animation.play("faceplant");
                    playState.playerHasDied();
                    Statics.PlayerDied = true;
                    Statics.PlayerHasDiedToMinions();
                    return;
                }
            }
            facing = determineFacing(potentialDirection);
            playDamageAnimation(facing);
        } else if (areControlsActive && !parentState.isTransitioningStates) {
            if (controls.attack.check() && !attacking) {

                attacking = true;
                attack(facing);
                Timer.delay(() -> {
                    attacking = false;
                }, 200);
                facing = determineFacing(potentialDirection);
                playAnimation(facing, null, attacking);
            }

            if (FlxG.keys.justPressed.H){
                attacking = false;
            }

            var directionVector:FlxPoint = null;
            if (!attacking){
                directionVector = MathHelpers.NormalizeVector(potentialDirection);
                directionVector.scale(delta*activeStats.speed);
                setPosition(x + directionVector.x, y + directionVector.y);
                facing = determineFacing(potentialDirection);
                playAnimation(facing, directionVector, attacking);
                updateLightOffset();
            }
        }
    }

    function updateLightOffset() {
        if (facing == FlxObject.UP) {
            lightOffset.set(0, -14);
        } else if (facing == FlxObject.DOWN) {
            lightOffset.set(0, -11);
        } else if (facing == FlxObject.LEFT) {
            lightOffset.set(-5, -11);
        } else if (facing == FlxObject.RIGHT) {
            lightOffset.set(5, -11);
        }
    }

    function playAnimation(_facing:Int, _directionVector:FlxPoint, _attacking:Bool){

        if (_attacking){
            switch _facing {
                case FlxObject.RIGHT:
                    animation.play("swipe_right");
                case FlxObject.DOWN:
                    animation.play("swipe_down");
                case FlxObject.LEFT:
                    animation.play("swipe_left");
                case FlxObject.UP:
                    animation.play("swipe_up");
            }
            return;
        }

        if (_directionVector == null || _directionVector.x == 0 && _directionVector.y == 0){
            switch _facing {
                case FlxObject.RIGHT:
                    animation.play("stand_right");
                case FlxObject.DOWN:
                    animation.play("stand_down");
                case FlxObject.LEFT:
                    animation.play("stand_left");
                case FlxObject.UP:
                    animation.play("stand_up");
            }
        } else {
            switch _facing {
                case FlxObject.RIGHT:
                    animation.play("walk_right", animation.curAnim.curFrame);
                case FlxObject.DOWN:
                    animation.play("walk_down", animation.curAnim.curFrame);
                case FlxObject.LEFT:
                    animation.play("walk_left", animation.curAnim.curFrame);
                case FlxObject.UP:
                    animation.play("walk_up", animation.curAnim.curFrame);
            }
        }
    }

    function playDamageAnimation(_facing:Int){
        switch _facing {
            case FlxObject.RIGHT:
                animation.play("stand_right");
            case FlxObject.DOWN:
                animation.play("stand_down");
            case FlxObject.LEFT:
                animation.play("stand_left");
            case FlxObject.UP:
                animation.play("stand_up");
        }
    }

    public function applyDamage(_damage:Int) {
        health -= _damage;
        if (health == 1){
            Timer.delay(() -> {
                TextPop.pop(Std.int(x-6), Std.int(y+3), "Health", new SlowFade(FlxColor.RED), 7);
                TextPop.pop(Std.int(x-5), Std.int(y+12), "Low", new SlowFade(FlxColor.RED), 7);
                FmodManager.PlaySoundOneShot(FmodSFX.PlayerAlmostDead);
            }, 500);
        }
    }

    public function setKnockback(_knockbackDirection:FlxPoint, _knockbackSpeed:Float, _knockbackDuration:Float) {
        inKnockback = true;
        if (shovel != null) {
            shovel.destroy();
        }
        knockbackDirection = _knockbackDirection;
        knockbackSpeed = _knockbackSpeed;
        knockbackDuration = _knockbackDuration;

        FlxFlicker.flicker(this, knockbackDuration*4);
        invincibilityTimeLeft = knockbackDuration*4;
    }

    function attack(facing:Int) {

        if (shovel != null){
            shovel.destroy();
        }

        var attackLocation:FlxPoint;
        var hitboxSize:FlxPoint;

        switch facing {
            case FlxObject.RIGHT:
                hitboxSize = new FlxPoint(20, 30);
                attackLocation = new FlxPoint(x+size.x/2, y+(size.y/2)-(hitboxSize.y/2)-playerHitboxOffsetY);
            case FlxObject.DOWN:
                hitboxSize = new FlxPoint(30, 20);
                attackLocation = new FlxPoint(x+(size.x/2)-(hitboxSize.x/2)-playerHitboxOffsetX, y+size.y/8);
            case FlxObject.LEFT:
                hitboxSize = new FlxPoint(20, 30);
                attackLocation = new FlxPoint(x-hitboxSize.x, y+(size.y/2)-(hitboxSize.y/2)-playerHitboxOffsetY);
            case FlxObject.UP:
                hitboxSize = new FlxPoint(30, 20);
                attackLocation = new FlxPoint(x+(size.x/2)-(hitboxSize.x/2)-playerHitboxOffsetX, y-hitboxSize.y-playerHitboxOffsetY/2);
            default:
                hitboxSize = new FlxPoint(20, 20);
                attackLocation = new FlxPoint(x, y);
        }
        var hitbox = new Hitbox(.2, attackLocation, hitboxSize);
        parentState.addHitbox(hitbox);

        var hitboxInteractSize = new FlxPoint(5, 5);
        var interactLocation:FlxPoint;
        switch facing {
            case FlxObject.RIGHT:
                hitboxInteractSize = new FlxPoint(13, 5);
                interactLocation = new FlxPoint(x+4, y);
            case FlxObject.DOWN:
                hitboxInteractSize = new FlxPoint(5, 13);
                interactLocation = new FlxPoint(x+2, y+6);
            case FlxObject.LEFT:
                hitboxInteractSize = new FlxPoint(13, 5);
                interactLocation = new FlxPoint(x-9, y);
            case FlxObject.UP:
                hitboxInteractSize = new FlxPoint(5, 13);
                interactLocation = new FlxPoint(x, y-10);
            default:
                interactLocation = new FlxPoint(x, y);
        }
        var hitboxInteract = new HitboxInteract(.2, interactLocation, hitboxInteractSize);
        parentState.addHitboxInteract(hitboxInteract);
        if (canAttack) {
            FmodManager.PlaySoundAndAssignId(FmodSFX.ShovelSwing, "attack");
            spawnShovel(hitbox.getMidpoint(), facing);
        } else {
            // Hack to let the player always move when they cannot spawn a shovel
            attacking = false;
        }
    }

    public function stopAttack() {
        if (shovel != null){
            shovel.destroy();
        }
        playAnimation(facing, null, false);
        FmodManager.StopSoundImmediately("attack");
    }

    function spawnShovel(position:FlxPoint, facing:Int) {
        shovel = new FlxSprite();
        parentState.addToWorld(shovel);
        shovel.loadGraphic(AssetPaths.weapons__png, true, 16, 32);

        var swingFrames = [0,1,2,3,4,5,6,7];
        var swingLeftFrames = [25,24,23,22,21,20,19,18];

        if (hasUpgrade("Pickaxe")) {
            for (i in 0...swingFrames.length) {
                swingFrames[i] += 9;
            }
            for (i in 0...swingLeftFrames.length) {
                swingLeftFrames[i] += 9;
            }
        }

        // 30 originally
        var animationSpeed = 30;
        shovel.animation.add("swing", swingFrames, animationSpeed, false);
        shovel.animation.add("swing_left", swingLeftFrames, animationSpeed, false);
        shovel.animation.finishCallback = (name) -> {
            shovel.destroy();
        }
        shovel.setMidpoint(position.x, position.y);
        shovel.animation.callback = shovelAnimCallback;

        switch facing {
            case FlxObject.RIGHT:
                shovel.angle = 0;
                shovel.animation.play("swing");
            case FlxObject.DOWN:
                shovel.angle = 90;
                shovel.animation.play("swing");
            case FlxObject.LEFT:
                shovel.animation.play("swing_left");
            case FlxObject.UP:
                shovel.angle = 270;
                shovel.animation.play("swing");
                shovel.ID = 998;
            default:
                shovel.angle = 225;
                shovel.animation.play("swing");
        }
    }

    public function shovelAnimCallback(name:String, frameNumber:Int, frameIndex:Int):Void {
        if (name == "swing") {
            if (frameNumber == 8) {
                shovel.destroy();
            }
        }

        switch facing {
            case FlxObject.RIGHT:
                if (frameNumber == 0){
                    shovel.y-=4;
                } else {
                    shovel.y+=1;
                }
            case FlxObject.DOWN:
                if (frameNumber == 0){
                    shovel.x+=4;
                } else {
                    shovel.x-=1;
                }
            case FlxObject.LEFT:
                if (frameNumber == 0){
                    shovel.y-=4;
                } else {
                    shovel.y+=1;
                }
            case FlxObject.UP:
                if (frameNumber == 0){
                    shovel.y+=4;
                    shovel.x-=4;
                } else {
                    shovel.x+=1;
                }
            default:

        }
	}

    function readDirectionInput():FlxPoint {

        var _potentialDirection = new FlxPoint(0, 0);

        if (controls.up.check()) {
            _potentialDirection.add(0, -1);
        }

		if (controls.down.check()) {
            _potentialDirection.add(0, 1);
        }

		if (controls.left.check()) {
            _potentialDirection.add(-1, 0);
        }

		if (controls.right.check()) {
            _potentialDirection.add(1, 0);
        }

        return _potentialDirection;
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
            return FlxObject.UP;
        } else if (vector.y > 0) {
            return FlxObject.DOWN;
        }

        return facing;
    }

    public function addUpgrade(upgradeMaker:() -> Upgrade) {
        state.upgradeMakers.push(upgradeMaker);
        var upgrade = upgradeMaker();
        upgrades.push(upgrade);
        addModifier(upgrade.modifier);
        organizeUpgrades();
    }

    public function organizeUpgrades() {
        var needsAdded = true;
        var xPos = 0;
        for (i in 0...upgrades.length) {
            needsAdded = true;

            parentState.addUIElement(upgrades[i]);
            upgrades[i].revive();

            // check if this upgrade overrides one before it
            for (k in 0...i) {
                if (upgrades[i].overrides(upgrades[k].name)) {
                    // this overrides a previous upgrade

                    // use the previous one's position
                    upgrades[i].x = upgrades[k].x;
                    upgrades[i].y = upgrades[k].y;

                    // kill the previous
                    upgrades[k].kill();

                    // add this one
                    needsAdded = false;
                }

                if (upgrades[k].overrides(upgrades[i].name)) {
                    // a previous upgrade overrides this one

                    // kill this one and nothing else is needed
                    upgrades[i].kill();
                    needsAdded = false;
                }
            }

            if (needsAdded) {
                parentState.addUIElement(upgrades[i]);
                upgrades[i].x = xPos * 32;
                upgrades[i].y = FlxG.height - upgrades[i].height;

                xPos++;
            }
        }
    }

    public function rejuvenate() {
        refresh();
        Player.state.activeStats.currentHealth = Player.state.baseStats.maxHealth;
        health = Player.state.activeStats.currentHealth;
    }
}
