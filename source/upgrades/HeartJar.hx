package upgrades;

class HeartJar extends Upgrade {
    public function new() {
        super();
        name = "Heart Jar";
        loadGraphic(AssetPaths.hudStuff__png, true, 32, 32);

        animation.add("inventory", [13]);
        animation.play("inventory");
    }

    override public function getDescription():String {
        return "A jar with two hearts";
    }
}