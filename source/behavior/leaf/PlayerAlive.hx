package behavior.leaf;

import entities.Player;
import behavior.tree.NodeStatus;
import behavior.tree.DecoratorNode;
import behavior.tree.Node;

class PlayerAlive extends DecoratorNode {
    public function new(child:Node) {
        super(child);
    }

    override public function doProcess(delta:Float):NodeStatus {
        if (context.get("navBundle") != null) {
            if (cast(context.get("navBundle"), NavBundle).player.alive) {
                return child.process(delta);
            }
        }

        return FAIL;
    }
}