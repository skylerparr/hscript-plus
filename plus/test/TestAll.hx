package;

import utest.Runner;
import utest.ui.Report;

import cases.ClassUtilTest;
import cases.ScriptStateTest;
import cases.ParserPlusTest;
import cases.InterpPlusTest;
import cases.ClassEmulationTest;

class TestAll  {
	public static function main() {
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}

	static function addTests(runner:Runner) {
		runner.addCase(new ClassUtilTest());
		runner.addCase(new ScriptStateTest());
		runner.addCase(new ParserPlusTest());
		runner.addCase(new InterpPlusTest());
		runner.addCase(new ClassEmulationTest());
	}
}