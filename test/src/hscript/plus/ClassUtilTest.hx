package hscript.plus;

import massive.munit.Assert;

@:access(hscript.plus.ClassUtil)
class ClassUtilTest {
    public function new() {}

    @Test
	public function testIsDynamicObject() {
        Assert.isTrue(ClassUtil.isDynamicObject({ super:null }));
		Assert.isFalse(ClassUtil.isDynamicObject(ClassUtil));
        Assert.isFalse(ClassUtil.isDynamicObject(null));
	}

    @Test
    public function testGetFirstInHierarchy() {
        var s0 = { id:64 };
        var s1 = { super:s0, pos:[10, 20] };
        var s2 = { super:s1 };

        var pos = ClassUtil.getFirstInHierachy(s2, "pos");
        Assert.areEqual(s1.pos, pos);

        var id = ClassUtil.getFirstInHierachy(s2, "id");
        Assert.areEqual(s0.id, id);
    }

    @Test
    public function testIsHaxeClassName() {
        Assert.isTrue(ClassUtil.isHaxeClassName("Math"));
        Assert.isFalse(ClassUtil.isHaxeClassName("ClassNotExists"));
    }
}