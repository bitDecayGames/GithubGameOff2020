package;

import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;

// A place to put all those juicy globals
class Statics {
    // How many levels per tileset
    public static var SetDepth:Int = 2;

    public static var CurrentSet:Int = 1;
    public static var CurrentLevel:Int = 0;
    public static var GoingDown:Bool = false;

    public static var PlayerDied:Bool = false;

    public static var MaxLightRadius:Float = 75;
    public static var minLightRadius:Float = 10;
    public static var lightDrainRate:Float = 1; // units per second
    public static var CurrentLightRadius:Float = MaxLightRadius;

    public static var MatterConverterCharges:Int = 0;

    private static var furthestDepth = 0;

    public static function IncrementLevel() {
        CurrentLevel++;
        if (CurrentLevel > furthestDepth) {
            furthestDepth = CurrentLevel;
            Bitlytics.Instance().Queue(Metrics.MAX_DEPTH, furthestDepth);
        }
    }

    public static function DecrementLevel() {
        CurrentLevel--;
    }
}