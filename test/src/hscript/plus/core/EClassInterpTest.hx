package hscript.plus.core;

import massive.munit.Assert;
class EClassInterpTest extends TestScriptState {
    var Entity:Dynamic;

    override function execute(e:Expr) {
        return returnedValue = EClassInterp.createClassFromExpr(interp, e);
    }

    @:access(hscript.plus.InterpPlus)
    @Before
    override public function setup() {
        super.setup();
        interp.depth = 0;
        script = "
        class Entity {
            public function new() {
                return 0;
            }

            public function normal() {
                return 1;
            }
        }
        ";
        Entity = get("Entity");
    }

    @Test
    public function testName() {
        Assert.areEqual("Entity", Entity.__sname__);
    }

    @Test
    @TestDebug
    public function testFunctions() {
        var constructor = Reflect.field(Entity, "new");

        Assert.isNotNull(constructor);
        Assert.isNotNull(Entity.normal);

        Assert.areEqual(0, constructor());
        Assert.areEqual(1, Reflect.field(Entity, "normal")());
    }
}