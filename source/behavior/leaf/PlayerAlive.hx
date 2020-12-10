package behavior.leaf;

import entities.Player;
import com.bitdecay.behavior.tree.NodeStatus;
import com.bitdecay.behavior.tree.decorator.DecoratorNode;
import com.bitdecay.behavior.tree.Node;

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