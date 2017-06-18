package cases;

import utest.Assert;

using hscript.plus.ClassUtil;

class InterpPlusTest extends SimpleScriptStateTest {
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
		script = '
		public function main()
			Assert.pass();
		';

		var main = returnedValue;
		main();
	}

	public function testPackageName() {
		script = 'package test;';

		Assert.equals("test", packageName);
	}

	public function testImport() {
		script = '
		import utest.Assert;

		Assert.pass();
		';
	}

	public function testNew() {
		script = '
		class Object {
			public function new()
				Assert.pass();
		}

		new Object();
		';
	}

	public function testThis() {
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
		Assert.pass();
		";
	}

	public function testVariableDeclaredWithoutValueNoError() {
		script = "
		class VarDecWitValNoEr {
			var sprite;
    	}

		Assert.pass();
		";
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
		class Player {}

		Assert.pass();
		';
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
		test.getNum();
		';
		Assert.equals(10, returnedValue);
	}
}