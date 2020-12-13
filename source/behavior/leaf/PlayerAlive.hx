package behavior.leaf;

import flixel.FlxSprite;
import entities.Player;
import com.bitdecay.behavior.tree.NodeStatus;
import com.bitdecay.behavior.tree.decorator.DecoratorNode;
import com.bitdecay.behavior.tree.Node;

class PlayerAlive extends DecoratorNode {
    public function new(child:Node) {
        super(child);
    }

    override public function doProcess(delta:Float):NodeStatus {
        if (context.get("player") != null) {
            if (cast(context.get("player"), FlxSprite).alive) {
                return child.process(delta);
            }
        }

        return FAIL;
    }
}