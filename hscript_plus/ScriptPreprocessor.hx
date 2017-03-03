package hscript_plus;

import hscript_plus.ScopeManager;

using StringTools;

typedef ScriptClass = {
	name:String,
	members:Array<String>,
	statics:Array<String>
}

class ScriptPreprocessor {
	public static inline var NEWLINE = #if windows "\r\n" #else "\n" #end;
	
	/**
	 * I recommend this website to write regular expressions
	 * http://regexr.com/
	 */
	public static var importRegex:EReg = ~/import\s+([^;]+);/g;
	public static var packageRegex:EReg = ~/package\s?([^;]+)?;/g;
	public static var classRegex:EReg = ~/class\s+(\w+)(?:\s+extends\s+(\w+))?\s*({?)/g;
	public static var superRegex:EReg = ~/super(?:\.(\w+))?\((.*)\);/g;
	public static var constructorCallRegex:EReg = ~/new\s+(\w+)\s*\((.*)\)/g;
	public static var functionRegex:EReg = ~/(?:(override)\s+)?(?:(public|private)\s+)?(?:(static)\s+)?(?:(inline)\s+)?function\s+(\w+)\((.*)\)\s*(\{+)?/g;
	public static var varRegex:EReg = ~/(?:(public|private)?\s+)?(?:(static)\s+)?(?:(inline)\s+)?var\s+(\w+)\s*(?::\s*(?:\w+)\s*)?(\s*=\s*[^\s].*)?/g;
	public static var bracketRegex:EReg = ~/({|})/g;
	
	public var imports:Array<String>;
	public var packageName:String;
	public var classes:Array<String> = [];
	
	var className:String;
	
	var scope:ScopeManager = new ScopeManager();
	var scopeName:String;
	var scopeType:ScopeType;
	
	public function new() {}
	
	public function process(script:String):String {
		var 
		lines = script.split(NEWLINE),
		index = 0;
		
		packageName = "";
		imports = [];
		classes = [];
		
		for (line in lines) {
			// if line starts with `package`
			if (packageRegex.match(line)) {
				packageName = packageRegex.matched(1);
				lines[index] = "";
			}
			// if line starts with `import`
			else if (importRegex.match(line)) {
				imports.push(importRegex.matched(1));
				lines[index] = "";
			}
			// if line starts with `class`
			else if (classRegex.match(line)) {
				className = classRegex.matched(1);
				var baseClass = classRegex.matched(2);
				var bracket = classRegex.matched(3);
				var processed = '$className = ' +
					if (baseClass == null)
						'{};';
					else '${ScriptClassUtil.CLASS_NAME}.classExtends($baseClass);';
				
				processed += ' $bracket';// + 'setVariable("$className", $className);';
				lines[index] = classRegex.replace(line, processed);
				
				scopeName = className;
				scopeType = CLASS_SCOPE;
				classes.push(className);
			}
			else if (superRegex.match(line)) {
				var superFunction = superRegex.matched(1);
				var args = superRegex.matched(2);
				
				if (superFunction == null)
					superFunction = "new";
				
				lines[index] = superRegex.replace(line, '$className.__superClass.$superFunction(this, $args);');
			}
			// if line has `new ClassName(..)`
			else if (constructorCallRegex.match(line)) {
				className = constructorCallRegex.matched(1);
				var args = constructorCallRegex.matched(2);
				
				lines[index] = constructorCallRegex.replace(line, 
				'${ScriptClassUtil.CLASS_NAME}.create($className, [$args])');
			}
			// if line has a public or static or public static function
			/**
			* Removes access modifier
			* https://haxe.org/manual/class-field-access-modifier.html
			*/
			else if (functionRegex.match(line)) {				
				var isOverriden = functionRegex.matched(1) != null;
				var isPublic = functionRegex.matched(2) == "public";
				var isStatic = functionRegex.matched(3) != null;
				var isInline = functionRegex.matched(4) != null;
				var funcName = functionRegex.matched(5);
				var params = functionRegex.matched(6);
				var bracket = functionRegex.matched(7);
				
				var classFunctionAssign = "";
				
				scopeName = funcName;
				scopeType = FUNCTION_SCOPE;
				
				// stop here if function is outside of class or inside another function
				if (!scope.isTopScope() && scope.type == CLASS_SCOPE && !isStatic) {
					// comma trailing `this` parameter
					var comma = params != "" ? ", " : "";
					// add `this` as the first parameter
					params = 'this:Dynamic$comma' + params;
					classFunctionAssign = '$className.$funcName =';
				}
				lines[index] = functionRegex.replace(line, '$classFunctionAssign function $funcName($params) $bracket');
			}
			else if (varRegex.match(line)) {
				var isPublic = varRegex.matched(1) == "public";
				var isStatic = varRegex.matched(2) != null;
				var isInline = varRegex.matched(3) != null;
				var varName = varRegex.matched(4);
				var assignment = varRegex.matched(5);
				
				/*if (scope.type == CLASS_SCOPE) {
					if (isStatic)
						scriptClass.statics.push(varName);
					else scriptClass.members.push(varName);
				}*/
				
				if (scope.type == CLASS_SCOPE) {
					lines[index] = varRegex.replace(line, '$className.$varName $assignment');
				}
			}
			
			if (bracketRegex.match(line)) {
				var bracket:String = bracketRegex.matched(1);
				
				var pos:Int = 0;
				do {
					if (bracket == "{") {
						scope.openScope(scopeName, scopeType);
					}
					else if (bracket == "}") {
						scope.closeScope();
					}
				// stops if no more bracket matched
				line = bracketRegex.matchedRight();
				pos = bracketRegex.matchedPos().pos;
				
				// without this, it would crash on neko, at least
				if (pos >= line.length) break;
				} while (bracketRegex.matchSub(line, pos));
			}
			
			// reset scope data
			scopeName = "";
			scopeType = ANONYMOUS_SCOPE;
			index++;
		}
		
		script = lines.join(NEWLINE);
		return script;
	}
	
}