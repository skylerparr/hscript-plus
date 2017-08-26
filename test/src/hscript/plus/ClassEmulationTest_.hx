package hscript.plus;

import massive.munit.Assert;
import hscript.Expr;

class ClassEmulationTest_ extends TestScriptState {
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
		Assert.areEqual(50, player.__super__.mass);
	}

	@Test
	public function testIncrement() {
		script = 'player.mass++';

		Assert.areEqual(101, player.__super__.mass);
	}

	@Test
	public function testDecrement() {
		script = 'player.mass--';

		Assert.areEqual(99, player.__super__.mass);
	}

	@Test
	public function testPlusEqual() {
		script = 'player.mass += 50';

		Assert.areEqual(150, player.__super__.mass);
	}

	@Test
	public function testMinusEqual() {
		script = 'player.mass -= 50';

		Assert.areEqual(50, player.__super__.mass);
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
		var expected = EField(EField(EIdent("player"), "__super__"), "mass");

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
	public function testHaxeClassInheritance() {
		script = " 
		import Sprite; 
	
		class Player extends Sprite {}
	
		player = new Player();
		player.setMass(10);
		player.mass;
		"; 
		Assert.areEqual(10, returnedValue); 
	}

	@Test
	public function testInheritance() {
		script = "
		class GameObject {
			public var exists:Bool = true;

			public function destroy() {
				exists = false;
			}
		}

		class PhysicalObject extends GameObject {}
		
		object = new PhysicalObject();
		object.destroy();
		";

		var object = get("object");
		Assert.isFalse(object.exists);
	}

	@Test
	public function testMultipleInheritance() {
		script = "
		class GameObject {
			public var exists:Bool = true;

			public function destroy() {
				exists = false;
			}
		}

		class PhysicalObject extends GameObject {
			public var mass:Float = 1;

			public function setMass(newMass:Float) {
				mass = newMass;
			}
		}

		class SpriteObject extends PhysicalObject {}

		sprite = new SpriteObject();
		sprite.setMass(25);
		sprite.destroy();
		";

		var sprite = get("sprite");
		Assert.areEqual(25, sprite.mass);
		Assert.isFalse(sprite.exists);
	}

	@Test
	public function testHaxeClassMultipleInheritance() {
		script = "
		import Sprite;

		class Rock extends Sprite {
			public var material:Int = 89741;
		}
		class Stone extends Rock {}
		class Hammer extends Stone {}
		
		hammer = new Hammer();
		hammer.setMass(5);
		hammer.mass;
		";

		var hammer = get("hammer");
		Assert.areEqual(5, returnedValue);
		Assert.areEqual(89741, hammer.material);
	}
}