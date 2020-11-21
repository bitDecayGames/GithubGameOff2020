package behavior.leaf.util;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import behavior.tree.LeafNode;
import behavior.tree.NodeStatus;

class PickTargetInRange extends LeafNode {
    public function new() {}

    override public function process(delta:Float):NodeStatus {
        if (context.get("navBundle") != null) {
            var nav = cast(context.get("navBundle"), NavBundle);
            var range = cast(context.get("range"), Float);

            var start = cast(context.get("self"), FlxSprite);

            for (i in 0...10) {
                var mod = FlxPoint.get(1, 0).scale(FlxG.random.float(range/4, range)).rotate(FlxPoint.weak(), FlxG.random.float(0, 360));
                if (!nav.level.navigationLayer.overlapsPoint(start.getPosition().addPoint(mod))) {
                    context.set("target", mod);
                    return SUCCESS;
                }
            }
        }

        return FAIL;
    }
}