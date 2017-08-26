package hscript.plus.core;

@:access(hscript.plus.ClassUtil)
class ObjectCreator {
	public static function create(scriptClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		if (args == null) args = [];
		return new ObjectCreator()._create(scriptClass, args);
	}

	var scriptObject:Dynamic;

	var scriptClass:Dynamic;
	var args:Dynamic;
	var superClass:Dynamic;

	var fieldName:String;
	var field:Dynamic;

	public function new() {}

	function _create(scriptClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		this.scriptClass = scriptClass;
		this.args = args;

		createScriptObject();
		extractSuperClass();
		createSuperClassObject();
		processMethods();

		return scriptObject;
	}

	function createScriptObject() {
		scriptObject = Reflect.copy(scriptClass);
	}

	function extractSuperClass() {
		if (Reflect.hasField(scriptClass, "__super__"))
			superClass = scriptClass.__super__;
		else superClass = null;
	}

	function createSuperClassObject() {
		if (superClass == null) return;

		if (ClassUtil.isEitherHaxeClassOrInstance(superClass))
			createHaxeObject();
		else createSuperClassObjectRecursively();
	}

	function createHaxeObject() {
		scriptObject.__super__ = Type.createInstance(superClass, args);
	}

	function createSuperClassObjectRecursively() {
		var superClassObject = create(superClass, args);
		if (ClassUtil.isEitherHaxeClassOrInstance(superClassObject.__super__))
			scriptObject.__super__ = superClassObject.__super__;
	}

	function processMethods() {
		for (name in getMethods()) {
			fieldName = name;
			field = getFieldValue(fieldName);

			if (fieldName == "new") {
				callThenDeleteField();
				continue;
			}

			bindObjectToMethod();
			attachMethodToObject();
		}
	}

	function getMethods() {
		return Reflect.fields(scriptObject).filter((name:String) -> {
			fieldName = name;
			field = getFieldValue(fieldName);
			return Reflect.isFunction(field);
		});
	}

	inline function getFieldValue(fieldName:String) {
		return Reflect.field(scriptObject, fieldName);
	}

	function callThenDeleteField() {
		callMethod(field);
		deleteField(fieldName);
	}
	
	function callMethod(method:Dynamic) {
		return Reflect.callMethod(scriptObject, method, [scriptObject].concat(args));
	}

	function deleteField(name:String) {
		Reflect.deleteField(scriptObject, name);
	}

	var method:Array<Dynamic>->Dynamic;

	function bindObjectToMethod() {
		var methodField = field;
		this.method = function(args:Array<Dynamic>):Dynamic {
			try {
				return Reflect.callMethod(scriptObject, methodField, [scriptObject].concat(args));
			}
			catch (e:Dynamic) {
				trace('Called from $fieldName: $e');
				return null;
			}
		}
	}

	function attachMethodToObject() {
		Reflect.setField(scriptObject, fieldName, Reflect.makeVarArgs(method));
	}
}