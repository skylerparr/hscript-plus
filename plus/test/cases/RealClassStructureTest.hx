package cases;

import hscript.plus.ClassUtil;
import hscript.plus.InterpPlus;
import hscript.plus.ParserPlus;
import utest.Assert;

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

	inline function executeScript(script:String) {
		return execute(ast = getAst(script));
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
		Assert.equals(100, executeScript("player.__super.health"));
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
}

class Sprite {
	public var health:Int;
	public function new() {
		health = 100;
	}
}