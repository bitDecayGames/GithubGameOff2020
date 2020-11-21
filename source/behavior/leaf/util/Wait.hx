package behavior.leaf.util;

import flixel.FlxG;
import behavior.tree.BTContext;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class Wait extends LeafNode {
    var started:Bool;
    var remaining:Float;

    public function new() {}

    override public function init(context:BTContext) {
        super.init(context);
        started = false;
        remaining = 0;
    }

    override public function process(delta:Float):NodeStatus {
        if (remaining <= 0) {
            if (started) {
                return SUCCESS;
            } else {
                var min = cast(context.get("minWait"), Float);
                var max = min;
                if (context.get("maxWait") != null) {
                    max = cast(context.get("maxWait"), Float);
                }
                remaining = FlxG.random.float(min, max);
                started = true;
            }
        }

        remaining -= delta;
        return RUNNING;
    }
}