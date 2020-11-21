package behavior.leaf.util;

import behavior.tree.LeafNode;
import behavior.tree.NodeStatus;

class Succeed extends LeafNode {
    public function new() {}

    override public function doProcess(delta:Float):NodeStatus {
        return SUCCESS;
    }
}