package misc;

class Macros {
	// Shorthand for retrieving compiler flag values.
	public static macro function getDefine(key : String) : haxe.macro.Expr {
		return macro $v{haxe.macro.Context.definedValue(key)};
	}

	// Shorthand for setting compiler flags.
	  public static macro function setDefine(key : String, value : String) : haxe.macro.Expr {
		haxe.macro.Compiler.define(key, value);
		return macro null;
	}

	// Shorthand for checking if a compiler flag is defined.
	public static macro function isDefined(key : String) : haxe.macro.Expr {
		return macro $v{haxe.macro.Context.defined(key)};
	}
}