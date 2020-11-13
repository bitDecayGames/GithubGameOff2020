package behavior.tree;

class BTContext {
    private var contents:Map<String, Dynamic>;

    public function new() {
        contents = new Map<String, Dynamic>();
    }

    public function get(key:String):Dynamic {
        return contents.get(key);
    }

    public function set(key:String, value:Dynamic) {
        contents.set(key, value);
    }
}