package behavior.tree;

class LeafNode implements Node {
    var context:BTContext;

    public function init(context:BTContext) {
        this.context = context;
    }

    public function process(delta:Float):NodeStatus {
        return FAIL;
    }
}