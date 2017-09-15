package hscript.plus.core;

typedef CnewType = String->Array<Dynamic>->Dynamic;
typedef ResolveType = String->Dynamic;

@:access(hscript.plus.InterpPlus)
class Cnew {
	static var interp:InterpPlus;

    public static function newClass(interp:InterpPlus, className:String, args:Array<Dynamic>):Dynamic {
		Cnew.interp = interp;
        return createNewClass(className, args);
	}

    static function createNewClass(className:String, args:Array<Dynamic>):Dynamic {
		if (ClassUtil.isHaxeClassName(className))
			return interp.superCnew(className, args);
		else return createDynamicClass(className, args);
	}

	static function createDynamicClass(className:String, args:Array<Dynamic>) {
		var dynamicClass = interp.superResolve(className);
		return ClassUtil.create(interp, "", dynamicClass, null, args);
	}
}