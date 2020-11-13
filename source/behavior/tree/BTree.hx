package behavior.tree;

import entities.Enemy;

class BTree implements Node {
    private var root:Node;
    private var context:BTContext;

    public function new(root:Node) {
        if (root == null) {
			throw "Root cannot be null";
        }

        this.root = root;
    }

    public function init(context:BTContext) {
        if (context == null) {
			context = new BTContext();
        }

        this.context = context;
        root.init(context);
    }

    public function process(delta:Float):NodeStatus {
        return root.process(delta);
    }
}