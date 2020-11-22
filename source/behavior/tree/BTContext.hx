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

    public function dump():String {
        var entries = new Array<String>();
        for (key => value in contents) {
            entries.push([key, value].join(":"));
        }

        return entries.join("\n");
    }
}