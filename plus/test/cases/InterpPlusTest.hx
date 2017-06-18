package cases;

import hscript.Expr;
import hscript.plus.ClassUtil;
import hscript.plus.InterpPlus;
import hscript.plus.ParserPlus;
import utest.Assert;

class InterpPlusTest {
	var parser:ParserPlus;
	var interp:InterpPlus;
	var script(default, set):String;
	var ast:Expr;
	var returnedValue:Dynamic;
	var traceOnce:Bool = false;

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
		if (traceOnce) {
			trace(ast);
			traceOnce = false;
		}
	}

	inline function execute() {
		return returnedValue = interp.execute(ast);
	}

	inline function get(name:String) {
		return interp.variables.get(name);
	}

	inline function set(name:String, value:Dynamic) {
		interp.variables.set(name, value);
	}

	public function new() {}

	public function setup() {
		interp = new InterpPlus();
		parser = new ParserPlus();
	}

	public function testNotNull() {
		script = 'class Object {}';

		Assert.notNull(get("Object"));
	}

	public function testVariable() {
		script = '
		class Object {
			var mass:physics.Mass = 10;
		}
		';

		var object = returnedValue;
		Assert.equals(10, object.mass);
	}

	public function testFunction() {
		set("pass", Assert.pass);
		script = '
		public function main()
			pass();
		';

		var main = returnedValue;
		main();
	}

	public function testPackageName() {
		script = 'package test;';

		Assert.equals("test", interp.packageName);
	}

	public function testImport() {
		script = '
		import utest.Assert;

		Assert.pass();
		';
	}

	public function testNew() {
		set("Assert", Assert);
		script = '
		class Object {
			public function new()
				Assert.pass();
		}

		new Object();
		';
	}

	public function testThisKeyword() {
		set("Assert", Assert);
		script = '
		class Object {
			var mass:Float = 0;
			public function new(mass:Float) {
				this.mass = mass;
			}

			public function assert(value) {
				Assert.equals(value, mass);
			}
		}
		';

		var mass = 20;
		var Object = returnedValue;
		var object = ClassUtil.create(Object, [mass]);
		object.assert(mass);
	}

	public function testStaticFunctionWithVarDeclareNoError() {
		script = "
		class StatFuncVarDecNoEr {
            public static function main() {
                var x = 10;
            }
    	}

		main();
		";
		Assert.pass();
	}

	public function testVariableDeclaredWithoutValueNoError() {
		var script = "
		class VarDecWitValNoEr {
			var sprite;
    	}
		";
		Assert.pass();
	}

	public function testWithoutThis() {
		script = '
		class WithoutThis {
			var x:Int;
			public function new() {
				x = 0;
			}
		}
		';
		var WithoutThis = returnedValue;
		var withoutThis = ClassUtil.create(WithoutThis);
		Assert.equals(0, withoutThis.x);
	}

	public function testSetGlobalField() {
		script = '
		class SetGlobalField {
			public function new() {
				pass = true;
			}
		}
		';
		var SetGlobalField = returnedValue;
		var setGlobalField = ClassUtil.create(SetGlobalField);
		Assert.isTrue(setGlobalField.pass);
	}

	public function testMultipleClassNoError() {
		script = '
		class Entity {}
		class Player {}';
		Assert.pass();
	}

	public function testFunctionReturnValue() {
		script = '
		class FunctionReturnValue {
			public function new() {}

			public function getNum() {
				return 10;
			}
		}

		var test = new FunctionReturnValue();
		num = test.getNum();
		';
		Assert.equals(10, returnedValue);
	}
}