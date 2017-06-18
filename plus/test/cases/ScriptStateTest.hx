package cases;

import utest.Assert;
import hscript.plus.ScriptState;

class ScriptStateTest {
    var state:ScriptState;
    var script(default, set):String;
    var returnedValue:Dynamic;

    function set_script(newScript:String) {
        script = newScript;
        return returnedValue = state.executeString(newScript);
        return newScript;
    }    

    public function new() {}

    public function setup() {
        state = new ScriptState();
    }

    public function testReadmeUsageExample() {
        var script = "
        class TestObject {
            public static function main() {
                var object = new TestObject(10, 10);
                object.name = NAME;
                Assert.equals('Ball', object.name);
            }
            
            public var x:Float = 0;
            public var y:Float = 0;

            public function new(x:Float, y:Float) {
                this.x = x;
                this.y = y;
            }
        }
        ";
        state.set("Assert", Assert);
        state.set("NAME", "Ball"); // set a global variable
        state.executeString(script); // executes a String
		
        // get a global variable
        var TestObject = state.get("TestObject"); // get a global variable
        TestObject.main();
    }

    public function testClassCreated() {
        script = '
        class ClassCreated {
            public static function main() {
                return new ClassCreated(10);
            }

            public var mass:Float = 0;

            public function new(mass)
                this.mass = mass;
        }        
        ';
        var object = returnedValue;
        Assert.equals(10, object.mass);
    }

    public function testExecuteFile() {
        state.executeFile("plus/test/scripts/ExecuteFile.hx");
    }

    public function testMainFunctionAutoCalled() {
        script = "
        import utest.Assert;

        class MainFunctionAutoCalled {
            public static function main() {
                Assert.pass();
            }
        }
        ";
    }

    public function testImportOtherScript() {
        state.scriptDirectory = "plus/test/scripts/";
        script = "
        import ImportOtherScript;

        new ImportOtherScript();
        ";
    }
}   