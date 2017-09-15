package hscript.plus.core;

import massive.munit.Assert;
import hscript.Expr;

class EFieldInterpTest extends TestScriptState {
    public static var this_id:Expr = EField(EIdent("this"), "id");
    public static var Player_id:Expr = EField(EIdent("Player"), "id");

    var Entity:Dynamic;
    var Player:Dynamic;

    function expr(expr:Expr) {
        return EFieldInterp.interp(interp, expr);
    }

    @Before
    override public function setup() {
        super.setup();
        Entity = { id:32 };
        Player = DynamicCreator.create(interp, "", Entity);
        set("this", Player);
    }

    @Test
    public function testDynamicSuperObject() {
        Assert.areEqual(Player.super.id, expr(this_id));
    }

    @Test
    public function testOverrideField() {
        Player.id = 64;
        Assert.areEqual(Player.id, expr(this_id));
    }

    @Test
    public function test() {
        set("Player", Player);
        var id = EFieldInterp.interp(interp, Player_id);
        Assert.areEqual(Player.super.id, id);
    }
}