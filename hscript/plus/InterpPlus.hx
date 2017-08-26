package hscript.plus;

import hscript.Expr;
import hscript.plus.core.ClassImporter;
import hscript.plus.core.EClassInterp;
import hscript.plus.core.Cnew;

class InterpPlus extends Interp {
	public static var NULL_DYNAMIC = {};	

	var classImporter:ClassImporter;
	var eclassInterp:EClassInterp;

	public function new(importer:ClassImporter) {
		super();
		classImporter = importer;
		classImporter.setInterp(this);

		eclassInterp = new EClassInterp(this);
	}

	override public function expr(e:Expr):Dynamic {
		e = Tools.map(e, prependThis);
		e = prependSuper(e);

 		var ret = super.expr(e);
		
		if (ret != null)
			return ret;
		
		classImporter.importFromExpr(e);
		return eclassInterp.createClassFromExpr(e);
	}

	function prependThis(e:Expr) {
		switch (edef(e)) {
			case EIdent(id) if (!locals.exists(id) && !variables.exists(id)):
				var thisObject = locals.get("this");
				if (thisObject != null) {
					thisObject = thisObject.r;
					e = mk(EField(EIdent("this"), id));
				}
			default:
		}
		return e;
	}

	function prependSuper(e:Expr):Expr {
		switch (edef(e)) {
			case EField(ident, fieldName):
				var object = super.expr(ident);
				if (ClassUtil.superHasField(object, fieldName))
					e = mk(EField(EField(ident, "__super__"), fieldName), e);
			
			case EBlock(_) | EFunction(_, _, _, _):
			// don't Tools.map(e, prependSuper) the cases or there will be bugs
			default:
				e = Tools.map(e, prependSuper);
		}
		return e;
	}

	override function cnew(className:String, args:Array<Dynamic>):Dynamic {
		return Cnew.newClass(superCnew, superResolve, className, args);
	}

	function superCnew(className:String, args:Array<Dynamic>) {
		return super.cnew(className, args);
	}

	function superResolve(className:String) {
		return super.resolve(className);
	}

	inline function mk(e, ?expr:Expr) : Expr {
		#if hscriptPos
		if( e == null ) return null;
		return { e : e, pmin: expr.pmin, pmax: expr.pmax, line: expr.line, origin: expr.origin };
		#else
		return e;
		#end
	}
}