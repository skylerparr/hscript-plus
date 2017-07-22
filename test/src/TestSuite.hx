import massive.munit.TestSuite;

import hscript.plus.ClassUtilTest;
import hscript.plus.core.ClassCreatorTest;
import hscript.plus.core.ObjectCreatorTest;
import hscript.plus.InterpPlusTest;
import hscript.plus.ParserPlusTest;
import hscript.plus.ScriptStateTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(hscript.plus.ClassUtilTest);
		add(hscript.plus.core.ClassCreatorTest);
		add(hscript.plus.core.ObjectCreatorTest);
		add(hscript.plus.InterpPlusTest);
		add(hscript.plus.ParserPlusTest);
		add(hscript.plus.ScriptStateTest);
	}
}
