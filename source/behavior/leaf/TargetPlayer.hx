package behavior.leaf;

import entities.Player;
import behavior.tree.NodeStatus;
import behavior.tree.Node;
import behavior.tree.DecoratorNode;

class TargetPlayer extends DecoratorNode {
    public function new(child:Node) {
        super(child);
    }

    override public function doProcess(delta:Float):NodeStatus {
        if (context.get("navBundle") != null) {
            context.set("target", cast(context.get("navBundle"), NavBundle).player.getMidpoint());
        }

        return child.process(delta);
    }
}