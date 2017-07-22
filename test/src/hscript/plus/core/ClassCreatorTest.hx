package hscript.plus.core;

import massive.munit.Assert;
class ClassCreatorTest {
    var Player:Dynamic;

    public function new() {}

    @Before
    public function setup() {
        Player = ClassUtil.createClass(Sprite);
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
}