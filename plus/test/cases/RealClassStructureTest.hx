package cases;

import hscript.plus.ClassUtil;
import hscript.plus.InterpPlus;
import hscript.plus.ParserPlus;
import utest.Assert;
import hscript.Expr;

@:access(hscript.plus.InterpPlus)
class RealClassStructureTest {
	var parser:ParserPlus;
	var interp:InterpPlus;
	
	var Player:Dynamic;
	var player:Dynamic;

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

	public function new() {
		Player = ClassUtil.createClass(Object);
	}

	public function setup() {
		interp = new InterpPlus();
		parser = new ParserPlus();

		player = ClassUtil.create(Player);
		set("player", player);
		set("Player", Player);
	}

	public function testClassValue() {
		script = "Player";
		Assert.equals(Player.__super, returnedValue);
	}

	public function testExpr() {
		script = "player.mass";
		Assert.equals(100, returnedValue);
	}

	public function testAssignment() {
		script = 'player.mass = 50';
		Assert.equals(50, player.__super.mass);
	}

	public function testIncrement() {
		script = 'player.mass++';

		Assert.equals(101, player.__super.mass);
	}

	public function testDecrement() {
		script = 'player.mass--';

		Assert.equals(99, player.__super.mass);
	}

	public function testPlusEqual() {
		script = 'player.mass += 50';

		Assert.equals(150, player.__super.mass);
	}

	public function testMinusEqual() {
		script = 'player.mass -= 50';

		Assert.equals(50, player.__super.mass);
	}

	public function testBooleanOperators() {
		script = 'player.mass == 100';
		Assert.isTrue(returnedValue);

		script = 'player.mass < 150';
		Assert.isTrue(returnedValue);

		script = 'player.mass > 150';
		Assert.isFalse(returnedValue);
	}

	public function testClassValueInFunctionCall() {
		set("wrap", v -> v);
		script = "wrap(Player)";

		Assert.equals(Player.__super, returnedValue);
	}

	public function testAccessSuperIdent() {
		var e = EIdent("player");
		var expected = EField(e, "__super");

		Assert.same(expected, interp.accessSuper(e));
	}

	public function testAccessSuperField() {
		var e = EField(EIdent("player"), "mass");
		var expected = EField(EField(EIdent("player"), "__super"), "mass");

		Assert.same(expected, interp.accessSuper(e));
	}
}