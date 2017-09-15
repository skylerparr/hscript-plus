import massive.munit.TestSuite;

import hscript.plus.ClassUtilTest;
import hscript.plus.core.ClassImporterTest;
import hscript.plus.core.DynamicCreatorTest;
import hscript.plus.core.ECallInterpTest;
import hscript.plus.core.EClassInterpTest;
import hscript.plus.core.EFieldInterpTest;
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
		add(hscript.plus.core.ClassImporterTest);
		add(hscript.plus.core.DynamicCreatorTest);
		add(hscript.plus.core.ECallInterpTest);
		add(hscript.plus.core.EClassInterpTest);
		add(hscript.plus.core.EFieldInterpTest);
		add(hscript.plus.InterpPlusTest);
		add(hscript.plus.ParserPlusTest);
		add(hscript.plus.ScriptStateTest);
	}
}
