package hscript.plus.core;

@:access(hscript.plus.ClassUtil)
class ClassCreator {
    static var newClass:Dynamic;

    static var _name:String;
    static var _superClass:Dynamic;
    static var _body:Dynamic;

    public static function create(?name:String, ?superClass:Dynamic, ?body:Dynamic):Dynamic {
		newClass = {};
        _name = name == null ? "" : name;
        _superClass = superClass;
        _body = body;
		
		copyIfSuperClassIsDynamic();
        setBasicProperties();
        copyFromBody();
		
		return newClass;
	}

    static function copyIfSuperClassIsDynamic() {
        if (ClassUtil.isDynamic(_superClass))
            copySuperClass();
    }

    static function copySuperClass() {
        newClass = Reflect.copy(_superClass);
        deleleStaticFields();
    }

    static function deleleStaticFields() {
		var statics:Array<String> = cast _superClass.__statics__;
		for (field in statics)
			Reflect.deleteField(newClass, field);
	}

    static function setBasicProperties() {
        newClass.__name__ = _name;
		newClass.__super__ = _superClass;
    }

    static function copyFromBody() {
        for (fieldName in Reflect.fields(_body))
			Reflect.setField(newClass, fieldName, Reflect.field(_body, fieldName));
    }
}