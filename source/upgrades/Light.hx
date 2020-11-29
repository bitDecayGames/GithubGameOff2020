package upgrades;

class Light extends Upgrade {
    public function new() {
        super();
        name = "LED Bulb";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [8]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "Super bright light bulb";
    }
}