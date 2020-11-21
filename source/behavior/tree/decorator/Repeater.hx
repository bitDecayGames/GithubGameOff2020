package behavior.tree.decorator;

class Repeater extends DecoratorNode {
    public function new(child:Node) {
        super(child);
    }

    override public function doProcess(delta:Float):NodeStatus {
        child.process(delta);
        return RUNNING;
    }
}