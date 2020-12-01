package states;

import config.Configure;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad.FlxDPadMode;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.UiHelpers;

class Section {
    public var role:FlxText;
    public var creators:Array<FlxText>;

    public function new() {
        role = new FlxText();
        creators = new Array<FlxText>();
    }
}
class CreditsState extends FlxUIState {

    var _allCreditElements:Array<FlxSprite>;

    var _txtCreditsTitle:FlxText;
    var _txtThankYou:FlxText;
    var _sections:Array<Section>;


    override public function create():Void {
        super.create();
        bgColor = FlxColor.TRANSPARENT;

        // Credits
        _allCreditElements = new Array<FlxSprite>();
        _sections = new Array<Section>();
        _txtCreditsTitle = new FlxText();
        _txtThankYou = new FlxText();

        _txtCreditsTitle.size = 40;
        _txtCreditsTitle.alignment = FlxTextAlign.CENTER;
        _txtCreditsTitle.text = "Credits";
        _txtCreditsTitle.setPosition(FlxG.width/2 - _txtCreditsTitle.width/2, FlxG.height);
        add(_txtCreditsTitle);
        _allCreditElements.push(_txtCreditsTitle);

        for (entry in Configure.getCredits()) {
            AddSectionToCreditsTextArrays(entry.sectionName, entry.names, _sections);
        }

        var creditsTextVerticalOffset = FlxG.height * 1.5;

        for (sec in _sections) {
            sec.role.setPosition(0, creditsTextVerticalOffset);
            creditsTextVerticalOffset += 25;

            for (creator in sec.creators) {
                creator.setPosition(10, creditsTextVerticalOffset);
                creditsTextVerticalOffset += 25;
            }

            creditsTextVerticalOffset += 25;
        }

        var flStudioLogo = new FlxSprite();
        flStudioLogo.loadGraphic(AssetPaths.FLStudioLogo__png);
        flStudioLogo.scale.set(.15, .15);
        flStudioLogo.updateHitbox();
        flStudioLogo.setPosition(0, creditsTextVerticalOffset);
        add(flStudioLogo);
        _allCreditElements.push(flStudioLogo);

        var fmodLogo = new FlxSprite();
        fmodLogo.loadGraphic(AssetPaths.FmodLogoWhite__png);
        fmodLogo.scale.set(.2, .2);
        fmodLogo.updateHitbox();
        fmodLogo.setPosition(5, creditsTextVerticalOffset + flStudioLogo.height);
        add(fmodLogo);
        _allCreditElements.push(fmodLogo);

        var haxeFlixelLogo = new FlxSprite();
        haxeFlixelLogo.loadGraphic(AssetPaths.HaxeFlixelLogo__png);
        haxeFlixelLogo.scale.set(.25, .25);
        haxeFlixelLogo.updateHitbox();
        haxeFlixelLogo.setPosition(fmodLogo.width + 30, creditsTextVerticalOffset + flStudioLogo.height + 10);
        add(haxeFlixelLogo);
        _allCreditElements.push(haxeFlixelLogo);

        _txtThankYou.size = 40;
        _txtThankYou.alignment = FlxTextAlign.CENTER;
        _txtThankYou.text = "Thank you!";
        _txtThankYou.setPosition(FlxG.width/2 - _txtThankYou.width/2, haxeFlixelLogo.y + FlxG.height + haxeFlixelLogo.height);
        add(_txtThankYou);
        _allCreditElements.push(_txtThankYou);
    }

    private function AddSectionToCreditsTextArrays(role:String, creators:Array<String>, sectionList:Array<Section>) {
        var section = new Section();

        var roleText = new FlxText();
        roleText.size = 15;
        roleText.text = role;
        add(roleText);
        section.role = roleText;
        _allCreditElements.push(roleText);

        for(creator in creators){
            var creatorText = new FlxText();
            creatorText.size = 15;
            creatorText.text = creator;
            creatorText.wordWrap = false;
            creatorText.autoSize = false;
            creatorText.alignment = FlxTextAlign.CENTER;
            creatorText.width = FlxG.width;

            section.creators.push(creatorText);
            add(creatorText);
            _allCreditElements.push(creatorText);
        }

        sectionList.push(section);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Stop scrolling when "Thank You" text is in the center of the screen
        if (_txtThankYou.y + _txtThankYou.height/2 < FlxG.height/2){
            return;
        }

        for(element in _allCreditElements) {
            if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed){
                element.y -= 2;
            } else {
                element.y -= .5;
            }
        }
    }

    function clickMainMenu():Void {
        FmodFlxUtilities.TransitionToState(new MainMenuState());
    }
}