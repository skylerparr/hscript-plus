package cases;

import massive.munit.Assert;
import hscript.plus.ClassUtil;

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
        Assert.isNotNull(player.__super);
    }
    
    @Test
    public function testFieldOfSuperObject() {
        var player = ClassUtil.create(Player);
        Assert.areEqual("", player.__super.name);
    }

    @Test
    public function testClassName() {
        var className = "Sprite";
        var Class = ClassUtil.createClass(className);
        Assert.areEqual(className, Class.className);
    }

    @Test
    public function testSuperClass() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller);
        
        Assert.areEqual(Controller, Keyboard.__super);
    }

    @Test
    public function testRealSuperClass() {
        Assert.areEqual(Sprite, Player.__super);
    }

    @Test
    public function testBodyParameter() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller, { enable:false });
        
        Assert.isNotNull(Keyboard.enable);
    }

    @Test
    public function testStaticFieldsRemoved() {
        var Entity:Dynamic = { pop:0, __statics:["pop"] };
        var Enemy:Dynamic = ClassUtil.createClass(Entity);

        Assert.isNull(Enemy.pop);
    }

    @Test
    public function testSuperHelperFunctions() {
        var sprite = { __super: new Sprite() };
        Assert.isTrue(ClassUtil.superHasField(sprite, "name"));
        Assert.isTrue(ClassUtil.superIsClass(sprite));
    }
}