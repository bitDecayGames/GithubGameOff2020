package upgrades;

import haxe.Timer;

class MatterConverter extends Upgrade {

    public var recharging:Bool = false;

    public function new() {
        super();
        name = "Matter Converter";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("0", [12]);
        animation.add("1", [18]);
        animation.add("2", [19]);
        animation.add("3", [20]);
        animation.add("4", [21]);
        animation.add("5", [22]);
        animation.add("6", [23]);
        animation.play("0");
    }

    override public function update(elapsed:Float) {
        switch (Statics.MatterConverterCharges) {
            case 0:
                animation.play("0");
            case 1:
                animation.play("1");
            case 2:
                animation.play("2");
            case 3:
                animation.play("3");
            case 4:
                animation.play("4");
            case 5:
                animation.play("5");
            default:
                if (!recharging){
                    recharging = true;
                    animation.play("6");
                    Timer.delay(() -> {
                        recharging = false;
                        animation.play("0");
                    }, 4000);
                }
                
        }
    }

    override public function getDescription():String {
        return "Turns meat into pure energy";
    }
}