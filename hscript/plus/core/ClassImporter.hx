package hscript.plus.core;

import hscript.Expr;

class ClassImporter {
	public static inline var PATH_PLACEHOLDER = "$PATH";
	public static inline var ERROR_MESSAGE = 'ClassImporter: $PATH_PLACEHOLDER not found';

	var globals:Map<String, Dynamic>;
    var resolveDynamicClass:String->Dynamic = name -> null;

	var path:String;
	var className:String;
	var classType:Dynamic;

    public function new(?resolveDynamicClass:String->Dynamic) {
		if (resolveDynamicClass != null)
			this.resolveDynamicClass = resolveDynamicClass;
    }

	public function setInterp(interp:InterpPlus) {
		globals = interp.variables;
	}

    public function importFromExpr(expr:Expr) {
    	extractClassPathFromExpr(expr);
        if (classPathExtractedSuccessfully())
            importClass();
    }

    function extractClassPathFromExpr(expr:Expr) {
        switch (ExprHelper.getExprDef(expr)) {
            case EImport(path):
                this.path = path;
            default:
				this.path = "";
        }
    }

    function classPathExtractedSuccessfully() {
        return path != "";
    }

    function importClass() {
		tryResolveClassType();
		throwErrorIfCannotResolve();
		getClassNameFromPath();
		addClassToGlobals();
	}

	function tryResolveClassType() {
		if (ClassUtil.classNameIsOfHaxeClass(path))
			classType = resolveHaxeClass(path)
		else classType = resolveDynamicClass(path);
	}

	function resolveHaxeClass(classNameOrPath:String) {
		return Type.resolveClass(classNameOrPath);
	}

	function throwErrorIfCannotResolve() {
		if (cannotResolveClassType())
			throw formatErrorMessage(path);
	}

	function cannotResolveClassType() {
		return classType == null;
	}

	function formatErrorMessage(invalidPath:String) {
		return StringTools.replace(ERROR_MESSAGE, PATH_PLACEHOLDER, invalidPath);
	}

	function getClassNameFromPath() {
		return className = path.split(".").pop();
	}

	function addClassToGlobals() {
		globals.set(className, classType);
	}
}