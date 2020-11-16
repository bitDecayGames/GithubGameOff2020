package behavior.leaf.position;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import entities.Player;
import behavior.tree.NodeStatus;
import behavior.tree.Node;
import behavior.tree.DecoratorNode;
import behavior.tree.BTContext;

class InlineWithTarget extends DecoratorNode {

    private var triggered:Bool = false;

    public function new(child:Node) {
        super(child);
    }

    override public function process(delta:Float):NodeStatus {
        if (context.get("target") == null) {
            return FAIL;
        }

        if (context.get("self") == null) {
            return FAIL;
        }

        if (triggered || cardinalAlignment(context.get("self"), context.get("target"))) {
            switch (child.process(delta)) {
                case SUCCESS:
                    triggered = false;
                    return SUCCESS;
                case FAIL:
                    triggered = false;
                    return FAIL;
                case RUNNING:
                    triggered = true;
                    return RUNNING;
            }
        } else {
            return FAIL;
        }
    }

    private function cardinalAlignment(a:FlxSprite, target:FlxPoint):Bool {
        var bundle = cast(context.get("navBundle"), NavBundle);

        var tileA = bundle.level.navigationLayer.getTileIndexByCoords(a.getMidpoint());
        var tileB = bundle.level.navigationLayer.getTileIndexByCoords(target);
        var tileAPos = bundle.level.navigationLayer.getTileCoordsByIndex(tileA, true);
        var tileBPos = bundle.level.navigationLayer.getTileCoordsByIndex(tileB, true);

        if (tileAPos.x == tileBPos.x || tileAPos.y == tileBPos.y) {
            return true;
        } else {
            return false;
        }
    }
}