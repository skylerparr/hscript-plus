import massive.munit.TestSuite;

import cases.ClassEmulationTest;
import cases.ClassUtilTest;
import cases.InterpPlusTest;
import cases.ParserPlusTest;
import cases.ScriptStateTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(cases.ClassEmulationTest);
		add(cases.ClassUtilTest);
		add(cases.InterpPlusTest);
		add(cases.ParserPlusTest);
		add(cases.ScriptStateTest);
	}
}
