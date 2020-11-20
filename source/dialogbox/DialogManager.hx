package dialogbox;

import flixel.FlxCamera;
import haxefmod.FmodEvents.FmodCallback;
import haxefmod.FmodEvents.FmodEvent;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;


class DialogManager {

    var typewriterSoundId:String = "typewriterSoundId";
    var typeText:Dialogbox;
    var parentState:FlxState;
    var renderCamera:FlxCamera;
    
    public function new(_parentState:FlxState, _renderCamera:FlxCamera) {
        parentState = _parentState;
        renderCamera = _renderCamera;
        typeText = new Dialogbox(parentState, Dialogs.DialogArray[0], FlxKey.SPACE, AssetPaths.joystix_monospace__ttf);
        typeText.cameras = [renderCamera];
        parentState.add(typeText);
    }

    public function update() {
        if (typeText.getIsTyping()){
            if (!FmodManager.IsSoundPlaying(typewriterSoundId)){
                FmodManager.PlaySoundAndAssignId(FmodSFX.Type, typewriterSoundId);
            }
        } 
        if (typeText == null || !typeText.getIsTyping()) {
            if (FmodManager.IsSoundPlaying(typewriterSoundId)){
                FmodManager.StopSound(typewriterSoundId);
            }
        }
    }

    public function loadDialog(index:Int){
        if (typeText != null) {
            typeText.flxTypeText.kill();
            typeText.kill();
        }
        if (index >= Dialogs.DialogArray.length) {
        trace("index out of bounds for dialogs");
        return;
        }
        typeText = new Dialogbox(parentState, Dialogs.DialogArray[index], FlxKey.SPACE, AssetPaths.joystix_monospace__ttf);
        typeText.cameras = [renderCamera];
        parentState.add(typeText);
    }

    public function stopSounds() {
        FmodManager.StopSoundImmediately(typewriterSoundId);
    }

}