package;

// A place to put all those juicy globals
class Statics {
    // How many levels per tileset
    public static var SetDepth:Int = 2;

    public static var CurrentSet:Int = 1;
    public static var CurrentLevel:Int = 0;
    public static var GoingDown:Bool = false;

    public static var PlayerDied:Bool = false;

    public static var MaxLightRadius:Float = 100;
    public static var minLightRadius:Float = 15;
    public static var lightDrainRate:Float = 2; // units per second
    public static var CurrentLightRadius:Float = MaxLightRadius;

    public static var MatterConverterCharges:Int = 0;

    public static function IncrementLevel() {
        CurrentLevel++;
    }

    public static function DecrementLevel() {
        CurrentLevel--;
    }
}