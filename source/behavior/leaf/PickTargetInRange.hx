package behavior.leaf;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import com.bitdecay.behavior.tree.leaf.LeafNode;
import com.bitdecay.behavior.tree.NodeStatus;

class PickTargetInRange extends LeafNode {
    public function new() {}

    override public function doProcess(delta:Float):NodeStatus {
        if (context.get("navBundle") != null) {
            var nav = cast(context.get("navBundle"), NavBundle);
            var range = cast(context.get("range"), Float);

            var start = cast(context.get("self"), FlxSprite);

            for (i in 0...10) {
                var rot = FlxG.random.int(0, 360);
                if (context.get("cardinalLock") != null) {
                    rot = FlxG.random.int(0, 3) * 90;
                }
                var pos = start.getMidpoint();
                var mod = FlxPoint.get(1, 0).scale(FlxG.random.float(range/4, range)).rotate(FlxPoint.weak(), rot);
                var dest = pos.addPoint(mod);
                if (!nav.level.navigationLayer.overlapsPoint(dest)) {
                    context.set("target", dest);
                    return SUCCESS;
                }
            }
        }
        return FAIL;
    }
}