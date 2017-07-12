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
	public function testPrependSuperField() {
		var e = EField(EIdent("player"), "mass");
		var expected = EField(EField(EIdent("player"), "__super"), "mass");

		Assert.areEqual(expected, prependSuper(e));
	}

	@Test
	public function testInitializeMemberVariable() {
		script = "
		class InitializeMemberVariable extends Sprite {
			var speed:Int;

			public function new() {
				speed = 20;
			}
		}

		new InitializeMemberVariable().speed;
		";
		Assert.areEqual(20, returnedValue);
	}

	@Test
	public function testCallingSuperClassFunction() {
		script = " 
		import Sprite; 
	
		class Player extends Sprite { 
			public function new() { 
				setMass(10);
			} 
		} 
	
		var player = new Player();
		player.mass;
		"; 
		Assert.areEqual(10, returnedValue); 
	}
}