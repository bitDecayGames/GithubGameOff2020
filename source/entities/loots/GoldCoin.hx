package entities.loots;

class GoldCoin extends Loot {
    
    public function new(_x:Float, _y:Float) {
        super(_x, _y);
        coinType = "gold";
        coinValue = 5;
        super.loadGraphic(AssetPaths.gold_coin__png, true, 8, 8);
        loadAnimation();
    }
}