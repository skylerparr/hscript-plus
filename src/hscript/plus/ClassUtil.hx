package hscript.plus;

class ClassUtil {
	public static function create(baseClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		if (args == null) args = [];

		var _this:Dynamic = Reflect.copy(baseClass);
		var superClass:Dynamic = baseClass.__super;

		if (isClass(superClass))
			_this.__super = Type.createInstance(superClass, args);
		
		for (fieldName in Reflect.fields(_this)) {
			var field = Reflect.field(_this, fieldName);
			if (!Reflect.isFunction(field)) continue;
			
			// call `new()`
			if (fieldName == "new") {
				Reflect.callMethod(_this, field, [_this].concat(args));
				Reflect.deleteField(_this, "new");
				continue;
			}

			function method(?args:Array<Dynamic>):Dynamic {
				try {
					return Reflect.callMethod(_this, field, [_this].concat(args));
				}
				catch (e:Dynamic) {
					trace('Called from $fieldName: $e');
					return null;
				}
			}

			Reflect.setField(_this, fieldName, Reflect.makeVarArgs(method));
		}
		
		return _this;
	}

	public static inline function superHasField(object:Dynamic, fieldName:String) {
		return hasField(object.__super, fieldName);
	}

	static function hasField(object:Dynamic, fieldName:String) {
		return
		#if cpp
		Type.getInstanceFields(Type.getClass(object)).indexOf(fieldName) > -1;
		#else
		Reflect.hasField(object, fieldName);
		#end
	}

	public static inline function superIsClass(object:Dynamic) {
		return isStructure(object) && isClass(object.__super);
	}

	static inline function isStructure(object:Dynamic) {
		return object != null && Reflect.hasField(object, "__super");
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
		newClass.__super = baseClass;

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