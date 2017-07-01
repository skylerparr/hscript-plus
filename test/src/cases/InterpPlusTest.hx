package cases;

import massive.munit.Assert;
using hscript.plus.ClassUtil;

class InterpPlusTest extends SimpleScriptStateBase {
	@Test
	public function testNotNull() {
		script = 'class Object {}';

		Assert.isNotNull(get("Object"));
	}

	@Test
	public function testVariable() {
		script = '
		class Object {
			var mass:physics.Mass = 10;
		}
		';

		var object = returnedValue;
		Assert.areEqual(10, object.mass);
	}

	@Test
	public function testFunction() {
		script = '
		public function main()
			pass = true;';

		var main = returnedValue;
		main();
	}

	@Test
	public function testPackageName() {
		script = 'package test;';

		Assert.areEqual("test", packageName);
	}

	@Test
	public function testImport() {
		set("Assert", null);

		script = '
		import massive.munit.Assert;

		pass = true;
		Assert.isTrue(pass);
		';
	}

	@Test
	public function testSetGlobalField() {
		script = '
		class SetGlobalField {
			public static function set()
				pass = true;
		}

		SetGlobalField.set();
		';
		Assert.isTrue(pass);
	}

	@Test
	public function testNew() {
		script = '
		class New {
			public function new() {
				pass = true;
			}
		}

		new New();
		';
		Assert.isTrue(pass);
	}

	@Test
	public function testThis() {
		script = '
		class Object {
			var mass:Float = 0;
			public function new(mass:Float) {
				this.mass = mass;
			}

			public function assert(value) {
				Assert.areEqual(value, mass);
			}
		}
		';

		var mass = 20;
		var Object = returnedValue;
		var object = ClassUtil.create(Object, [mass]);
		object.assert(mass);
	}

	@Test
	public function testStaticFunctionWithVarDeclareNoError() {
		script = "
		class StatFuncVarDecNoEr {
            public static function main() {
                var x = 10;
            }
    	}

		main();
		";
	}

	@Test
	public function testVariableDeclaredWithoutValueNoError() {
		script = "
		class VarDecWitValNoEr {
			var sprite;
    	}
		";
	}

	@Test
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
		Assert.areEqual(0, withoutThis.x);
	}

	@Test
	public function testMultipleClassNoError() {
		script = '
		class Entity {}
		class Player {}
		';
	}

	@Test
	public function testFunctionReturnValue() {
		script = '
		class FunctionReturnValue {
			public static function getNum() {
				return 10;
			}
		}

		FunctionReturnValue.getNum();
		';
		Assert.areEqual(10, returnedValue);
	}
}