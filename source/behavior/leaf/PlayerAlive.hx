package behavior.leaf;

import entities.Player;
import behavior.tree.NodeStatus;
import behavior.tree.ParentNode;
import behavior.tree.Node;

class PlayerAlive extends ParentNode {
    public function new(child:Node) {
        super(child);
    }

    override public function process(delta:Float):NodeStatus {
        if (context.get("player") != null) {
            if (cast(context.get("player"), Player).alive) {
                return child.process(delta);
            }
        }

        return FAIL;
    }
}