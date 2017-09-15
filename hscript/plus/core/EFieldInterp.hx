package hscript.plus.core;

import hscript.Expr;

class EFieldInterp {
    @:access(hscript.plus.InterpPlus)
    public static function interp(interp:InterpPlus, e:Expr):Dynamic {
        switch (ExprHelper.getExprDef(e)) {
            case EField(e, f):
                var obj = interp.superExpr(e);
                if (ClassUtil.isDynamicObject(obj))
                    return ClassUtil.getFirstInHierachy(obj, f);
                else return interp.get(obj, f);

                /* var thisExists = interp.globals.exists("this");
                if (thisExists) {
                    var _this = interp.globals.get("this");
                    return ClassUtil.getFirstInHierachy(_this, f);
                }
                else {

                } */
            default: return null;
        }
    }
}    