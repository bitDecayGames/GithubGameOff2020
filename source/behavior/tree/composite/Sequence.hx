package behavior.tree.composite;

import flixel.FlxG;

class Sequence extends MultiParentNode {
    var index:Int;
    var lastIndex:Int;
    var lastStatus:NodeStatus;

    public function new(children:Array<Node>) {
        super(children);
    }

    override public function init(context:BTContext) {
        super.init(context);
        index = 0;
        lastIndex = -1;
    }

    override public function process(delta:Float):NodeStatus {
        if (lastIndex != index && index < children.length) {
            children[index].init(context);
            lastIndex = index;
        }

        lastStatus = children[index].process(delta);

        switch (lastStatus) {
            case SUCCESS:
                index++;
                if (index < children.length) {
                    return RUNNING;
                } else {
                    index = 0;
                    return SUCCESS;
                }
            case FAIL:
                index = 0;
                return FAIL;
            case RUNNING:
                return RUNNING;
        }
    }
}