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

    var current:String = "";
    var last:String = "";

    public function process(delta:Float):NodeStatus {
        #if debug
        context.set("debug_path", new Array<String>());
        #end

        var result = root.process(delta);

        #if debug
        var path:Array<String> = context.get("debug_path");
        for (i in 0...path.length) {
            path[i] = path[i].split(".").pop();
        }
        path.push(context.get("debug_result"));
        current = path.join(" -> ");

        if (current != last) {
            trace(current);
            last = current;
        }
        #end

        return result;
    }
}