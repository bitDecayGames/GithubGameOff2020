package upgrades;

class MatterConverter extends Upgrade {
    public function new() {
        super();
        name = "Matter Converter";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [12]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "Turns meat into pure energy";
    }
}