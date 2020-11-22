package behavior.leaf.util;

import behavior.tree.DecoratorNode;
import behavior.tree.NodeStatus;

class IfNoTarget extends DecoratorNode {

    override public function doProcess(delta:Float):NodeStatus {
        if (context.get("target") == null) {
            return child.process(delta);
        } else {
            return SUCCESS;
        }
    }
}