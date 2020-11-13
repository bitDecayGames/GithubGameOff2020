package behavior.leaf;

import entities.Player;
import behavior.tree.NodeStatus;
import behavior.tree.Node;
import behavior.tree.ParentNode;

class TargetPlayer extends ParentNode {
    public function new(child:Node) {
        super(child);
    }

    override public function process(delta:Float):NodeStatus {
        if (context.get("player") != null) {
            context.set("target", cast(context.get("player"), Player).getPosition());
        }

        return child.process(delta);
    }
}