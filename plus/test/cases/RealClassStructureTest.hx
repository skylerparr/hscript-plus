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

	var ast:hscript.Expr;

	public function new() {
		Player = ClassUtil.createClass(Sprite);
	}

	inline function getAst(script:String) {
		return parser.parseString(script);
	}

	inline function execute(ast) {
		return interp.execute(ast);
	}

	inline function executeScript(script:String, traceAST:Bool = false) {
		return execute(ast = getAst(script));
	}

	inline function executeScriptTraceAST(script:String) {
		ast = getAst(script);
		trace(ast);
		return execute(ast);
	}

	inline function set(name:String, value:Dynamic) {
		interp.variables.set(name, value);
	}

	public function setup() {
		interp = new InterpPlus();
		parser = new ParserPlus();
		player = ClassUtil.create(Player);
		set("player", player);
		set("Player", Player);
	}

	public function testClassValue() {
		Assert.equals(Player.__super, executeScript("Player"));
	}

	public function testExpr() {
		Assert.equals(100, executeScript("player.health"));
	}

	public function testAssignment() {
		executeScript('player.health = 50');
		Assert.equals(50, player.__super.health);
	}

	public function testIncrement() {
		executeScript('player.health++');
		Assert.equals(101, player.__super.health);
	}

	public function testDecrement() {
		var script = 'player.health--';
		var ast = getAst(script);
		execute(ast);

		Assert.equals(99, player.__super.health);
	}

	public function testPlusEqual() {
		var script = 'player.health += 50';
		var ast = getAst(script);
		execute(ast);

		Assert.equals(150, player.__super.health);
	}

	public function testClassValueInFunctionCall() {
		set("wrap", v -> v);
		Assert.equals(Player.__super, executeScript("wrap(Player)"));
	}

	public function testAccessSuperIdent() {
		var e = EIdent("player");
		Assert.same(EField(e, "__super"), interp.accessSuper(e));
	}

	public function testAccessSuperField() {
		var e = EField(EIdent("player"), "health");
		Assert.same(EField(EField(EIdent("player"), "__super"), "health"), interp.accessSuper(e));
	}
}

class Sprite {
	public var health:Int;
	public function new() {
		health = 100;
	}
}