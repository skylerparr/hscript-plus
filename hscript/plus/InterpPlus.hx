package hscript.plus;

import hscript.Expr;
import hscript.plus.core.*;

class InterpPlus extends Interp {
	public var globals(default, null):Map<String, Dynamic>;

	var classImporter:ClassImporter;
	var eclassInterp:EClassInterp;

	var exprSteps:Array<Expr->Dynamic> = [];

	override function get(o:Dynamic, f:String):Dynamic {
		var value = ClassUtil.getFirstInHierachy(o, f);
		if (value == null)
			value = super.get(o, f);
		return value;
	}

	override function resolve(id:String):Dynamic {
		var value:Dynamic = null;
		
		try {
			value = super.resolve(id);
		}
		catch (e:Error) {
			var object = globals.get("this");
			if (object != null)
				value = ClassUtil.getFirstInHierachy(object, id);
		}

		return value;
	}

	override function assign(e1:Expr, e2:Expr):Dynamic {
		var assignedValue = expr(e2);
		switch (edef(e1)) {
			case EIdent(id):
				var object = globals.get("this");
				if (object != null)
					Reflect.setField(object, id, assignedValue);
			default:
		}

		super.assign(e1, e2);
		return assignedValue;
	}

	public function new() {
		super();
		globals = variables;

		classImporter = new ClassImporter(this);

		pushExprStep(ECallInterp.expr.bind(this));
		pushExprStep(superExpr);
		pushExprStepVoid(classImporter.importFromExpr);
		pushExprStep(EClassInterp.createClassFromExpr.bind(this));
	}

	public function setResolveImportFunction(func:String->Dynamic) {
		classImporter.setResolveImportFunction(func);
	}

	function pushExprStepVoid(stepVoid:Expr->Void) {
		var  step = e -> { stepVoid(e); return null; };
		pushExprStep(step);
	}

	function pushExprStep(step:Expr->Dynamic) {
		exprSteps.push(step);
	}

	override public function expr(e:Expr):Dynamic {
		return startExprSteps(e);
	}

	function startExprSteps(e:Expr):Dynamic {
		var ret:Dynamic = null;
		for (step in exprSteps) {
			ret = step(e);
			if (ret != null)
				break;
		}
		return ret;
	}

	public function superExpr(e:Expr):Dynamic {
		return super.expr(e);
	}

	override function cnew(className:String, args:Array<Dynamic>):Dynamic {
		return Cnew.newClass(this, className, args);
	}

	function superCnew(className:String, args:Array<Dynamic>) {
		return super.cnew(className, args);
	}

	function superResolve(className:String) {
		return super.resolve(className);
	}
}