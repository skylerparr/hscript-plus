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
    public function testSuperHasField() {
        var sprite = { __super__: new Sprite() };
        Assert.isTrue(ClassUtil.superHasField(sprite, "name"));
        Assert.isTrue(ClassUtil.superHasField(sprite, "setMass"));
    }

    @Test
    public function testSuperIsHaxeClass() {
        var sprite = { __super__: new Sprite() };
        Assert.isTrue(ClassUtil.superIsHaxeClass(sprite));
        Assert.isTrue(ClassUtil.superIsHaxeClass(Player));
    }

    @Test
	public function testIsDynamic() {
        Assert.isTrue(ClassUtil.isDynamic(Player));
		Assert.isFalse(ClassUtil.isDynamic(Sprite));
	}

    @Test
    public function testIsHaxeClass() {
        Assert.isTrue(ClassUtil.isHaxeClass(Sprite));
        Assert.isFalse(ClassUtil.isHaxeClass(Player));
    }
}