package cases;

import massive.munit.Assert;
import hscript.plus.ClassUtil;
import hscript.Expr;

class ClassEmulationTest extends SimpleScriptStateBase {
	var Player:Dynamic;
	var player:Dynamic;

	@BeforeClass
	public function beforeClass() {
		Player = ClassUtil.createClass(Sprite);
	}

	@Before
	override public function setup() {
		super.setup();

		player = ClassUtil.create(Player);
		setMany
		({ "player": player,
		"Player": Player });
	}

	@Test
	public function testClassValue() {
		script = "Player";
		Assert.areEqual(Player.__super, returnedValue);
	}

	@Test
	public function testExpr() {
		script = "player.mass";
		Assert.areEqual(100, returnedValue);
	}

	@Test
	public function testAssignment() {
		script = 'player.mass = 50';
		Assert.areEqual(50, player.__super.mass);
	}

	@Test
	public function testIncrement() {
		script = 'player.mass++';

		Assert.areEqual(101, player.__super.mass);
	}

	@Test
	public function testDecrement() {
		script = 'player.mass--';

		Assert.areEqual(99, player.__super.mass);
	}

	@Test
	public function testPlusEqual() {
		script = 'player.mass += 50';

		Assert.areEqual(150, player.__super.mass);
	}

	@Test
	public function testMinusEqual() {
		script = 'player.mass -= 50';

		Assert.areEqual(50, player.__super.mass);
	}

	@Test
	public function testBooleanOperators() {
		script = 'player.mass == 100';
		Assert.isTrue(returnedValue);

		script = 'player.mass < 150';
		Assert.isTrue(returnedValue);

		script = 'player.mass > 150';
		Assert.isFalse(returnedValue);
	}

	@Test
	public function testClassValueInFunctionCall() {
		set("wrap", v -> v);
		script = "wrap(Player)";

		Assert.areEqual(Player.__super, returnedValue);
	}

	@Test
	public function testAccessSuperIdent() {
		var e = EIdent("player");
		var expected = EField(e, "__super");

		Assert.areEqual(expected, accessSuper(e));
	}

	@Test
	public function testAccessSuperField() {
		var e = EField(EIdent("player"), "mass");
		var expected = EField(EField(EIdent("player"), "__super"), "mass");

		Assert.areEqual(expected, accessSuper(e));
	}
}