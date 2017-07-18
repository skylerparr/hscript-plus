package hscript.plus;

import massive.munit.Assert;

@:access(hscript.plus.ClassUtil)
class ClassUtilTest {
    var Player:Dynamic;

    public function new() {}

    @Before
    public function setup() {
        Player = ClassUtil.createClass(Sprite);
    }

    @Test
    public function testCreateWithArgs() {
        var Player = ClassUtil.createClass({ "name": "" });
        // set new()
        Reflect.setField(Player, "new", (_this, name) -> _this.name = name);

        var name = "Bob";
        var player = ClassUtil.create(Player, [name]);

        Assert.areEqual(name, player.name);
    }

    @Test
    public function testSuperObject() {
        var player = ClassUtil.create(Player);
        Assert.isNotNull(player.__super__);
    }
    
    @Test
    public function testFieldOfSuperObject() {
        var player = ClassUtil.create(Player);
        Assert.areEqual("", player.__super__.name);
    }

    @Test
    public function testClassName() {
        var className = "Sprite";
        var Class = ClassUtil.createClass(className);
        Assert.areEqual(className, Class.__name__);
    }

    @Test
    public function testSuperClass() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller);
        
        Assert.areEqual(Controller, Keyboard.__super__);
    }

    @Test
    public function testRealSuperClass() {
        Assert.areEqual(Sprite, Player.__super__);
    }

    @Test
    public function testBodyParameter() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller, { enable:false });
        
        Assert.isNotNull(Keyboard.enable);
    }

    @Test
    public function testStaticFieldsRemoved() {
        var Entity:Dynamic = { pop:0, __statics__:["pop"] };
        var Enemy:Dynamic = ClassUtil.createClass(Entity);

        Assert.isNull(Enemy.pop);
    }

    @Test
    public function testSuperHasField() {
        var sprite = { __super__: new Sprite() };
        Assert.isTrue(ClassUtil.superHasField(sprite, "name"));
        Assert.isTrue(ClassUtil.superHasField(sprite, "setMass"));
    }

    @Test
    public function testSuperIsClass() {
        var sprite = { __super__: new Sprite() };
        Assert.isTrue(ClassUtil.superIsHaxeClass(sprite));
    }

    @Test
	public function testIsStructure() {
        Assert.isTrue(ClassUtil.isDynamic(Player));
		Assert.isFalse(ClassUtil.isDynamic(Sprite));
	}
}