package cases;

import utest.Assert;
import hscript.Expr;
import hscript.plus.ParserPlus;

@:access(hscript.plus.ParserPlus.expr)
class ParserPlusTest {
	var parser:ParserPlus;
	var script(default, set):String;
	var ast:Expr;

	function set_script(newScript:String) {
		ast = parser.parseString(newScript);
		return script = newScript;
	}

	public function new() {}

	public function setup() {
		parser = new ParserPlus();
	}

	inline function getExpr(?expr:Expr) {
		expr = expr == null ? ast : expr;
		return parser.expr(expr);
	}

	public function testClassName() {
		script = 'class Sprite {}';
		
		switch (getExpr()) {
			case EClass(name, _, _):
				Assert.equals("Sprite", name);
			default: Assert.fail();
		}
	}

	public function testBaseClassName() {
		script = 'class Sprite extends Object {}';
		
		switch (getExpr()) {
			case EClass(_, _, baseClass):
				Assert.equals("Object", baseClass);
			default: Assert.fail();
		}
	}

	public function testClassBodyIsABlock() {
		script = 'class Box {
			var mass:Float = 10;
			function new(this) {}
		}';
		
		switch (getExpr()) {
			case EClass(_, e, _):
				switch (getExpr(e)) {
					case EBlock(_): Assert.pass();
					default: Assert.fail();
				}
			default:
				Assert.fail();
		}
	}

	public function testAccessModifiers() {
		script = 'public inline static function build() {}';
		
		switch (getExpr()) {
			case EFunction(_, _, _, _, access):
				Assert.contains(APublic, access);
				Assert.contains(AInline, access);
				Assert.contains(AStatic, access);
			default: Assert.fail();
		}
	}

	public function testPackage() {
		script = 'package;';
		packageNameIs("");

		script = 'package test;';
		packageNameIs("test");

		script = 'package test.cases;';
		packageNameIs("test.cases");
	}

	function packageNameIs(name:String) {
		switch (getExpr()) {
			case EPackage(path):
				Assert.equals(name, path);
			default: Assert.fail();
		}
	}

	public function testImport() {
		var packages:Array<String> = ["test.TestClass", "physics.Box"];
		script = '
		import ${packages[0]};
		import ${packages[1]};
		';
		var ast = EBlock([EImport(packages[0]), EImport(packages[1])]);

		Assert.same(ast, getExpr());
	}
}