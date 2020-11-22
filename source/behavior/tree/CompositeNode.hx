package behavior.tree;

class CompositeNode implements Node {
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
        #if btree
        cast(context.get("debug_path"), Array<Dynamic>).push(Type.getClassName(Type.getClass(this)));
        #end

        var result = doProcess(delta);

        #if btree
        context.set("debug_result", result);
        #end

        return result;
    }

    public function doProcess(delta:Float):NodeStatus {
        return FAIL;
    }
}