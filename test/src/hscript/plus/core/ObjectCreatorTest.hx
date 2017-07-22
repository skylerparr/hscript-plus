package hscript.plus.core;

import massive.munit.Assert;
class ObjectCreatorTest {
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
}