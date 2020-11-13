package behavior.tree;

class MultiParentNode implements Node {
    var children:Array<Node>;
    var context:BTContext;

    public function new(children:Array<Node>) {
        this.children = children;
    }

    public function init(context:BTContext):Void {
        this.context = context;
        for (c in children) {
            c.init(context);
        }
    }

    public function process(delta:Float):NodeStatus {
        return FAIL;
    }
}