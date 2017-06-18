package;

import hscript.plus.ParserPlus;
import hscript.plus.InterpPlus;
import hscript.Expr;
import utest.Assert;

@:access(SimpleScriptState)
@:access(hscript.plus.InterpPlus.accessSuper)
class SimpleScriptStateTest {
	var state:SimpleScriptState;
	
	var script(default, set):String;
	var ast(get, never):Expr;
	var returnedValue(get, never):Dynamic;
	var packageName(get, never):String;

	function get_script() return state.script;
	function set_script(v:String) return state.script = v;

	function get_ast() return state.ast;
	function get_returnedValue() return state.returnedValue;

	function get_packageName() {
		return state.interp.packageName;
	}

	public function new() {}

	public function setup() {
		state = new SimpleScriptState();
		set("Assert", Assert);
	}

	public inline function get(name:String) {
		return state.interp.variables.get(name);
	}

	public inline function setMany(variables:Dynamic) {
		for (name in Reflect.fields(variables)) {
            var value = Reflect.field(variables, name);
            set(name, value);
        }
	}

	public inline function set(name:String, value:Dynamic) {
		return state.interp.variables.set(name, value);
	}

	public inline function requestTrace() {
		state.traceRequested = true;
	}

	public inline function accessSuper(e:Expr) {
		return state.interp.accessSuper(e);
	}
}

class SimpleScriptState {
    public var script(default, set):String;
	public var ast(default, null):Expr;
	public var returnedValue(default, null):Dynamic;
	
    var parser:ParserPlus;
    var interp:InterpPlus;
    var traceRequested:Bool = false;

    public function new() {
        parser = new ParserPlus();
        interp = new InterpPlus();
    }

	function set_script(newScript:String) {
		script = newScript;
		parseToAst();
		traceAstOnceIfRequest();
		execute();
		return newScript;
	}

	function parseToAst() {
		ast = parser.parseString(script);
	}

	function traceAstOnceIfRequest() {
		if (traceRequested) {
			trace(ast);
			traceRequested = false;
		}
	}

	inline function execute() {
		return returnedValue = interp.execute(ast);
	}
}