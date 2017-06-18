package cases;

import utest.Assert;
import hscript.plus.ClassUtil;

@:access(hscript.plus.ClassUtil)
class ClassUtilTest {
    public var Player:Dynamic;

    public function new() {}

    public function setup() {
        Player = ClassUtil.createClass(Object);
    }

    public function testCreateWithArgs() {
        var Player = ClassUtil.createClass({ "name": "" });
        // set new()
        Reflect.setField(Player, "new", (_this, name) -> _this.name = name);

        var name = "Bob";
        var player = ClassUtil.create(Player, [name]);

        Assert.equals(name, player.name);
    }

    public function testSuperObject() {
        var player = ClassUtil.create(Player);
        Assert.notNull(player.__super);
    }
    
    public function testFieldOfSuperObject() {
        var player = ClassUtil.create(Player);
        Assert.equals("", player.__super.name);
    }

    public function testClassName() {
        var className = "Object";
        var Class = ClassUtil.createClass(className);
        Assert.equals(className, Class.className);
    }

    public function testSuperClass() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller);
        
        Assert.equals(Controller, Keyboard.__super);
    }

    public function testRealSuperClass() {
        Assert.equals(Object, Player.__super);
    }

    public function testBodyParameter() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller, { enable:false });
        
        Assert.notNull(Keyboard.enable);
    }

    public function testStaticFieldsRemoved() {
        var Entity:Dynamic = { pop:0, __statics:["pop"] };
        var Enemy:Dynamic = ClassUtil.createClass(Entity);

        Assert.isNull(Enemy.pop);
    }

    public function testSuperHelperFunctions() {
        var object = { __super: new Object() };
        Assert.isTrue(ClassUtil.superHasField(object, "name"));
        Assert.isTrue(ClassUtil.superIsClass(object));
    }
}