package upgrades;

class MatterConverter extends Upgrade {
    public function new() {
        super();
        name = "Matter Converter";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [17]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "Turns meat into pure energy";
    }
}