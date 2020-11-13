package behavior.leaf.util;

import flixel.FlxG;
import behavior.tree.BTContext;
import behavior.tree.NodeStatus;
import behavior.tree.LeafNode;

class Wait extends LeafNode {
    var min:Float;
    var max:Float;

    var started:Bool;
    var remaining:Float;

    public function new(min:Float, max:Float = -1) {
        this.min = min;
        this.max = max;

        if (max == -1) {
            max = min;
        }
    }

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
                remaining = FlxG.random.float(min, max);
                started = true;
                trace("timer set to wait: " + remaining);
            }
        }

        remaining -= delta;
        return RUNNING;
    }
}