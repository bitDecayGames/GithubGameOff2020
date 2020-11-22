package behavior.tree.composite;

class Parallel extends CompositeNode {
    public function new(children:Array<Node>) {
        super(children);
    }

    override public function doProcess(delta:Float):NodeStatus {
        var result:NodeStatus = FAIL;
        var innerResult:NodeStatus;
        for (child in children) {
            innerResult = child.process(delta);

            if (innerResult == SUCCESS) {
                result = SUCCESS;
            } else if (innerResult == RUNNING && result == FAIL) {
                result = RUNNING;
            }
        }

        return result;
    }
}