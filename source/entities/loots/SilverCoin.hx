package entities.loots;

class SilverCoin extends Loot {
    
    public function new(_x:Float, _y:Float) {
        super(_x, _y);
        coinType = "silver";
        coinValue = 1;
        super.loadGraphic(AssetPaths.silver_coin__png, true, 8, 8);
        loadAnimation();
    }
}