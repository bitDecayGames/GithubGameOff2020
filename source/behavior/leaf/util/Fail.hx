package behavior.leaf.util;

import behavior.tree.DecoratorNode;
import behavior.tree.LeafNode;
import behavior.tree.NodeStatus;

class Fail extends DecoratorNode {
    override public function doProcess(delta:Float):NodeStatus {
        child.process(delta);
        return FAIL;
    }
}