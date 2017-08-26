package hscript.plus.core;

typedef CnewType = String->Array<Dynamic>->Dynamic;
typedef ResolveType = String->Dynamic;

class Cnew {
    static var createHaxeClass:CnewType;
    static var resolveDynamicClassName:ResolveType;

    public static function newClass(
    superCnew:CnewType, superResolve:ResolveType, 
    className:String, args:Array<Dynamic>):Dynamic {
		createHaxeClass = superCnew;
        resolveDynamicClassName = superResolve;

        return createNewClass(className, args);
	}

    static function createNewClass(className:String, args:Array<Dynamic>):Dynamic {
		if (ClassUtil.classNameIsOfHaxeClass(className))
			return createHaxeClass(className, args);
		else return createDynamicClass(className, args);
	}

	static function createDynamicClass(className:String, args:Array<Dynamic>) {
		var dynamicClass = resolveDynamicClassName(className);
		return ClassUtil.create(dynamicClass, args);
	}
}