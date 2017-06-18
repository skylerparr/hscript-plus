package cases;

import hscript.plus.ClassUtil;
import utest.Assert;
import hscript.Expr;

class ClassEmulationTest extends SimpleScriptStateTest {
	var Player:Dynamic;
	var player:Dynamic;

	public function new() {
		super();
		Player = ClassUtil.createClass(Sprite);
	}

	override public function setup() {
		super.setup();

		player = ClassUtil.create(Player);
		setMany
		({ "player": player,
		"Player": Player });
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

		Assert.same(expected, accessSuper(e));
	}

	public function testAccessSuperField() {
		var e = EField(EIdent("player"), "mass");
		var expected = EField(EField(EIdent("player"), "__super"), "mass");

		Assert.same(expected, accessSuper(e));
	}
}