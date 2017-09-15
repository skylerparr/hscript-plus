package hscript.plus.core;

import hscript.Expr;

class EClassInterp {
	static var interp:InterpPlus;
	static var globals:Map<String, Dynamic>;

    public static function createClassFromExpr(interp:InterpPlus, expr:Expr):Dynamic {
		EClassInterp.interp = interp;
		globals = interp.variables;

        switch (ExprHelper.getExprDef(expr)) {
			case EClass(name, e, superClassName):
				var superClass = getSuperClass(superClassName);
				var classType:Dynamic = ClassUtil.create(interp, name, superClass);

				globals.set(name, classType);

				switch (ExprHelper.getExprDef(e)) {
					case EBlock(exprList):
						for (e in exprList)
							addClassFields(classType, e);
					default:
				}
				return classType;
			default:
				return null;
		}
    }

	static function getSuperClass(superClassName:String) {
		return superClassName == null ? null : globals.get(superClassName);
	}

	static function addClassFields(classType:Dynamic, e:Expr) {
		switch (ExprHelper.getExprDef(e)) {
			case EFunction(args, _, name, _, access):
				setClassField(classType, name, e, access);
			case EVar(name, _, e, access):
				setClassField(classType, name, e, access);
			default:
		}
	}

	static function setClassField(object:Dynamic, name:String, e:Expr, access:Array<Access>) {
		var field = interp.superExpr(e);
		Reflect.setField(object, name, field);
	}
}