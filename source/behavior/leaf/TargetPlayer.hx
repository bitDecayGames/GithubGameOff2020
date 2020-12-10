package behavior.leaf;

import entities.Player;
import com.bitdecay.behavior.tree.NodeStatus;
import com.bitdecay.behavior.tree.Node;
import com.bitdecay.behavior.tree.decorator.DecoratorNode;

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