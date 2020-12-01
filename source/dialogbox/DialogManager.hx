package dialogbox;

import flixel.FlxCamera;
import haxefmod.FmodEvents.FmodCallback;
import haxefmod.FmodEvents.FmodEvent;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;


class DialogManager {

    public var isDone:Bool = true;
    var currentDialogIndex:Int = -1;

    var typewriterSoundId:String = "typewriterSoundId";
    var typeText:Dialogbox;
    var parentState:FlxState;
    var renderCamera:FlxCamera;
    var disableSounds:Bool;


    public function new(_parentState:FlxState, _renderCamera:FlxCamera) {
        parentState = _parentState;
        renderCamera = _renderCamera;
    }

    public function update() {
        if (disableSounds || typeText == null){
            return;
        }

        if (typeText.getIsTyping()){
            if (!FmodManager.IsSoundPlaying(typewriterSoundId)){
                FmodManager.PlaySoundAndAssignId(FmodSFX.Typewriter, typewriterSoundId);
            }
        }
        if (typeText == null || !typeText.getIsTyping()) {
            if (FmodManager.IsSoundPlaying(typewriterSoundId)){
                FmodManager.StopSound(typewriterSoundId);
            }
        }
    }

    public function loadDialog(index:Int, cost:Int = -1){
        isDone = false;
        if (typeText != null) {
            typeText.flxTypeText.kill();
            typeText.kill();
        }
        if (index >= Dialogs.DialogArray.length) {
        trace("index out of bounds for dialogs");
        return;
        }
        var textLines = Dialogs.DialogArray[index].copy();
        // if (cost != -1) {
        //     var costText = "$" + cost;
        //     textLines.insert(0, costText);
        // }
        typeText = new Dialogbox(parentState, this, textLines, FlxKey.SPACE, AssetPaths.eof_8__ttf);
        typeText.cameras = [renderCamera];
        parentState.add(typeText);
        currentDialogIndex = index;
    }

	public function getCurrentDialogIndex():Int {
        return currentDialogIndex;
	}

    public function stopSounds() {
        FmodManager.StopSoundImmediately(typewriterSoundId);
        disableSounds = true;
    }

    public function isTyping():Bool {
        if (typeText != null) {
            return typeText.getIsTyping();
        }
        return false;
    }
}