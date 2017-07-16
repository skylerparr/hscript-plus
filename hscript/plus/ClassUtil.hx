package hscript.plus;

import hscript.plus.core.ClassCreator;
import hscript.plus.core.ObjectCreator;

class ClassUtil {
	public static function createClass(?className:String, ?baseClass:Dynamic, ?body:Dynamic):Dynamic {
		return ClassCreator.create(className, baseClass, body);
	}

	public static function create(baseClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		return ObjectCreator.create(baseClass, args);
	}

	public static inline function superHasField(object:Dynamic, fieldName:String) {
		return superIsHaxeClass(object) && hasField(object.__super__, fieldName);
	}

	static inline function superIsHaxeClass(object:Dynamic) {
		return isDynamic(object) && isHaxeClass(object.__super__);
	}

	static inline function isDynamic(object:Dynamic) {
		return object != null && Reflect.hasField(object, "__super__");
	}

	static inline function isHaxeClass(object:Dynamic) {
		try {
			return Type.getClass(object) != null || Type.getClassName(object) != null;
		}
		catch (e:Dynamic) {
			return false;
		}
	}

	static function hasField(object:Dynamic, fieldName:String) {
		return Type.getInstanceFields(Type.getClass(object)).indexOf(fieldName) > -1;
	}
}