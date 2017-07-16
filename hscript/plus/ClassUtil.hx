package hscript.plus;

import hscript.plus.core.ObjectCreator;

class ClassUtil {
	public static function create(baseClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		return ObjectCreator.create(baseClass, args);
	}

	public static inline function superHasField(object:Dynamic, fieldName:String) {
		return superIsClass(object) && hasField(object.__super__, fieldName);
	}

	static function hasField(object:Dynamic, fieldName:String) {
		return Type.getInstanceFields(Type.getClass(object)).indexOf(fieldName) > -1;
	}

	public static inline function superIsClass(object:Dynamic) {
		return isStructure(object) && isClass(object.__super__);
	}

	static inline function isStructure(object:Dynamic) {
		return object != null && Reflect.hasField(object, "__super__");
	}

	static inline function isClass(object:Dynamic) {
		try {
			return Type.getClass(object) != null || Type.getClassName(object) != null;
		}
		catch (e:Dynamic) {
			return false;
		}
	}
	
	public static function createClass(?className:String, ?baseClass:Dynamic, ?body:Dynamic):Dynamic {
		var newClass:Dynamic = {};
		
		if (isStructure(baseClass)) { // baseClass is a Dynamic data structure
			newClass = Reflect.copy(baseClass);
			deleleStaticFields(newClass, baseClass);
		}

		newClass.className = className != null ? className : "";
		newClass.__super__ = baseClass;

		for (fieldName in Reflect.fields(body))
				Reflect.setField(newClass, fieldName, Reflect.field(body, fieldName));
		
		return newClass;
	}

	static function deleleStaticFields(newClass:Dynamic, baseClass:Dynamic) {
		var statics:Array<String> = baseClass.__statics;
		if (statics == null) return;

		for (field in statics)
			Reflect.deleteField(newClass, field);
	}
}