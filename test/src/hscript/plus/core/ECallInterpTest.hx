package hscript.plus.core;

import massive.munit.Assert;

class ECallInterpTest extends TestScriptState {
    @Test
    
    public function testThisInGlobals() {
        script = "
        class Entity {
            function me() {
                return this;
            }
        }
        Entity.me();
        ";
        var Entity = get("Entity");
        Assert.areEqual(Entity, returnedValue);
    }

    @Test
    
    public function testThisInGlobalsInConstructor() {
        script = "
        class Entity {
            function new() {
                return this;
            }
        }
        Entity.new();
        ";
        var Entity = get("Entity");
        Assert.areEqual(Entity, returnedValue);
    }

    @Test
	public function testWithoutThis() {
		script = '
		class WithoutThis {
			var x:Int = -1;
			public function new() {
				x = 0;
                return this;
			}
		}
        WithoutThis.new();
		';
        var WithoutThis = interp.globals.get("WithoutThis");
		Assert.areEqual(WithoutThis, returnedValue);
	}
}