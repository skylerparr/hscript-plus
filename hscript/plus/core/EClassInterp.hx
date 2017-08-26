package hscript.plus.core;

import hscript.Expr;

class EClassInterp {
	var interp:InterpPlus;
	var globals:Map<String, Dynamic>;

	public function new(interp:InterpPlus) {
		this.interp = interp;
		globals = interp.variables;
	}

    public function createClassFromExpr(expr:Expr) {
        switch (ExprHelper.getExprDef(expr)) {
			case EClass(name, e, superClassName):
				var superClass = getSuperClass(superClassName);
				var classType = ClassUtil.createClass(name, superClass, { __statics__:new Array<String>() });

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

	function getSuperClass(superClassName:String) {
		return superClassName == null ? null : globals.get(superClassName);
	}

	function addClassFields(classType:Dynamic, e:Expr) {
		switch (ExprHelper.getExprDef(e)) {
			case EFunction(args, _, name, _, access):
				if (!isStatic(access))
					args.unshift({ name:"this" });
				setClassField(classType, name, e, access);
			case EVar(name, _, e, access):
				setClassField(classType, name, e, access);
			default:
		}
	}

	inline function isStatic(access:Array<Access>) {
		return access != null && access.indexOf(AStatic) > -1;
	}

	function setClassField(object:Dynamic, name:String, e:Expr, access:Array<Access>) {
		Reflect.setField(object, name, interp.expr(e));
		if (isStatic(access))
			object.__statics__.push(name);
	}
}