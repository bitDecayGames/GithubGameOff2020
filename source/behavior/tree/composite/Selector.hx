package behavior.tree.composite;

class Selector extends CompositeNode {
    public function new(children:Array<Node>) {
        super(children);
    }

    override public function process(delta:Float):NodeStatus {
        var result:NodeStatus;
        for (child in children) {
            result = child.process(delta);

            if (result == FAIL) {
                continue;
            } else {
                return result;
            }
        }

        return FAIL;
    }
}