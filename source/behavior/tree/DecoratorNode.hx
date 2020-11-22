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