package upgrades;

class Light extends Upgrade {
    public function new() {
        super();
        name = "LED Bulm";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [4]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "Super bright light bulb";
    }
}