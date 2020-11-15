package behavior.tree;

class DecoratorNode implements Node {
    var child:Node;
    var context:BTContext;

    public function new(child:Node) {
        this.child = child;
    }

    public function init(context:BTContext) {
        this.context = context;
        if (child.init != null) {
            child.init(context);
        }
    }

    public function process(delta:Float):NodeStatus {
        return FAIL;
    }
}