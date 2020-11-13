package behavior.tree;

interface Node {
    public function init(context:BTContext):Void;
    public function process(delta:Float):NodeStatus;
}