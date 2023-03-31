package funkin.scripting;

import lime.app.Application;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.io.Path;
import hscript.IHScriptCustomConstructor;

/**
 * Class used for scripting.
 */
class Script extends FlxBasic implements IFlxDestroyable {
	/**
	 * Use "static var thing = true;" in hscript to use those!!
	 * are reset every mod switch so once you're done with them make sure to make them null!!
	 */
	public static var staticVariables:Map<String, Dynamic> = [];


	public static function getDefaultVariables(?script:Script):Map<String, Dynamic> {
		return [
			// Haxe related stuff
			"Std"			   => Std,
			"Math"			  => Math,
			"StringTools"	   => StringTools,
			"Json"			  => haxe.Json,

			// OpenFL & Lime related stuff
			"Assets"			=> openfl.utils.Assets,
			"Application"	   => lime.app.Application,
			"window"			=> lime.app.Application.current.window,

			// Flixel related stuff
			"FlxG"			  => flixel.FlxG,
			"FlxSprite"		 => flixel.FlxSprite,
			"FlxBasic"		  => flixel.FlxBasic,
			"FlxCamera"		 => flixel.FlxCamera,
			"state"			 => flixel.FlxG.state,
			"FlxEase"		   => flixel.tweens.FlxEase,
			"FlxTween"		  => flixel.tweens.FlxTween,
			"FlxSound"		  => flixel.system.FlxSound,
			"FlxAssets"		 => flixel.system.FlxAssets,
			"FlxMath"		   => flixel.math.FlxMath,
			"FlxGroup"		  => flixel.group.FlxGroup,
			"FlxTypedGroup"	 => flixel.group.FlxGroup.FlxTypedGroup,
			"FlxSpriteGroup"	=> flixel.group.FlxSpriteGroup,
			"FlxTypeText"	   => flixel.addons.text.FlxTypeText,
			"FlxText"		   => flixel.text.FlxText,
			"FlxTimer"		  => flixel.util.FlxTimer,
			"FlxPoint"		  => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
			"FlxAxes"		   => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
			"FlxColor"		  => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor"),

			// Engine related stuff
			"engine"			=> {
				commit: funkin.macros.GitCommitMacro.commitNumber,
				hash: funkin.macros.GitCommitMacro.commitHash,
				build: 2675, // 2675 being the last build num before it was removed
				name: "Codename Engine"
			},
			"ModState"		  => funkin.scripting.ModState,
			"ModSubState"	   => funkin.scripting.ModSubState,
			"PlayState"		 => funkin.game.PlayState,
			"GameOverSubstate"  => funkin.game.GameOverSubstate,
			"HealthIcon"		=> funkin.game.HealthIcon,
			"HudCamera"		 => funkin.game.HudCamera,
			"Note"			  => funkin.game.Note,
			"Strum"			 => funkin.game.Strum,
			"StrumLine"		 => funkin.game.StrumLine,
			"Character"		 => funkin.game.Character,
			"Boyfriend"		 => funkin.game.Character, // for compatibility
			"PauseSubstate"	 => funkin.menus.PauseSubState,
			"FreeplayState"	 => funkin.menus.FreeplayState,
			"MainMenuState"	 => funkin.menus.MainMenuState,
			"PauseSubState"	 => funkin.menus.PauseSubState,
			"StoryMenuState"	=> funkin.menus.StoryMenuState,
			"TitleState"		=> funkin.menus.TitleState,
			"Options"		   => funkin.options.Options,
			"Paths"			 => funkin.system.Paths,
			"Conductor"		 => funkin.system.Conductor,
			"FunkinShader"	  => funkin.shaders.FunkinShader,
			"CustomShader"	  => funkin.shaders.CustomShader,
			"FunkinText"		=> funkin.ui.FunkinText,
			"Alphabet"		  => funkin.ui.Alphabet,

			"CoolUtil"		  => funkin.utils.CoolUtil,
			"IniUtil"		   => funkin.utils.IniUtil,
			"XMLUtil"		   => funkin.utils.XMLUtil,
			#if sys "ZipUtil"   => funkin.utils.ZipUtil, #end
			"MarkdownUtil"	  => funkin.utils.MarkdownUtil,
			"EngineUtil"		=> funkin.utils.EngineUtil,
			"MemoryUtil"		=> funkin.utils.MemoryUtil,
			"BitmapUtil"		=> funkin.utils.BitmapUtil,
		];
	}
	public static function getDefaultPreprocessors():Map<String, Dynamic> {
		var defines = funkin.macros.DefinesMacro.defines;
		defines.set("CODENAME_ENGINE", true);
		defines.set("CODENAME_VER", Application.current.meta.get('version'));
		defines.set("CODENAME_BUILD", 2675); // 2675 being the last build num before it was removed
		defines.set("CODENAME_COMMIT", funkin.macros.GitCommitMacro.commitNumber);
		return defines;
	}
	/**
	 * All available script extensions
	 */
	public static var scriptExtensions:Array<String> = [
		"hx", "hscript", "hsc", "hxs",
		"lua" /** ACTUALLY NOT SUPPORTED, ONLY FOR THE MESSAGE **/
	];

	/**
	 * Currently executing script.
	 */
	public static var curScript:Script = null;

	/**
	 * Script name (with extension)
	 */
	public var fileName:String;

	/**
	 * Path to the script.
	 */
	public var path:String = null;

	/**
	 * Creates a script from the specified asset path. The language is automatically determined.
	 * @param path Path in assets
	 */
	public static function create(path:String):Script {
		if (Assets.exists(path)) {
			return switch(Path.extension(path).toLowerCase()) {
				case "hx" | "hscript" | "hsc" | "hxs":
					new HScript(path);
				case "lua":
					Logs.trace("Lua is not supported in this engine. Use HScript instead.", ERROR);
					new DummyScript(path);
				default:
					new DummyScript(path);
			}
		}
		return new DummyScript(path);
	}

	public static function createCustomClass(s:ScriptClass) {
		var t:Class<IScriptClassInstance> = cast Type.resolveClass('${s.classPath}__Softcoded');
		if (t == null) {
			Logs.trace('Class at ${s.classPath} was not found.', ERROR);
			return null;
		}
		return new ScriptCustomClass(s, t);
	}

	/**
	 * Creates a new instance of the script class.
	 * @param path
	 */
	public function new(path:String) {
		super();

		fileName = Path.withoutDirectory(path);
		this.path = path;
		onCreate(path);
		for(k=>e in getDefaultVariables(this)) {
			set(k, e);
		}
	}


	/**
	 * Loads the script
	 */
	public function load() {
		var oldScript = curScript;
		curScript = this;
		onLoad();
		curScript = oldScript;
	}

	/**
	 * HSCRIPT ONLY FOR NOW
	 * Sets the "public" variables map for ScriptPack
	 */
	public function setPublicMap(map:Map<String, Dynamic>) {

	}

	/**
	 * Hot-reloads the script, if possible
	 */
	public function reload() {

	}

	/**
	 * Traces something as this script.
	 */
	public function trace(v:Dynamic) {
		Logs.traceColored([
			Logs.logText('${fileName}: ', GREEN),
			Logs.logText(Std.string(v))
		], TRACE);
	}


	/**
	 * Calls the function `func` defined in the script.
	 * @param func Name of the function
	 * @param parameters (Optional) Parameters of the function.
	 * @return Result (if void, then null)
	 */
	public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
		var oldScript = curScript;
		curScript = this;

		var result = onCall(func, parameters == null ? [] : parameters);

		curScript = oldScript;
		return result;
	}

	/**
	 * Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instance` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
	 * @param variable Parent variable.
	 */
	public function setParent(variable:Dynamic) {}

	/**
	 * Gets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function get(variable:String):Dynamic {return null;}

	/**
	 * Gets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function set(variable:String, value:Dynamic):Void {}

	/**
	 * Shows an error from this script.
	 * @param text Text of the error (ex: Null Object Reference).
	 * @param additionalInfo Additional information you could provide.
	 */
	public function error(text:String, ?additionalInfo:Dynamic):Void {
		Logs.traceColored([
			Logs.logText(fileName, RED),
			Logs.logText(text)
		], ERROR);
	}

	/**
	 * PRIVATE HANDLERS - DO NOT TOUCH
	 */
	private function onCall(func:String, parameters:Array<Dynamic>):Dynamic {
		return null;
	}
	public function onCreate(path:String) {}

	public function onLoad() {}

	public function onDestroy() {};

	public function getClass(name:String):ScriptClass {
		return null;
	}

	public override function destroy() {
		super.destroy();
		onDestroy();
	}
}

class ScriptClass {
	public var classPath:String = null;
	public var folderlessPath:String = null;

	public function new() {}

	public function get(field:String):Dynamic {return null;}

	public function set(field:String, v:Dynamic) {}

	public function hasField(field:String):Bool {return false;}

	/**
	 * Calls the function `func` defined in the class.
	 * @param func Name of the function
	 * @param parameters (Optional) Parameters of the function.
	 * @return Result (if void, then null)
	 */
	 public function call(func:String, parameters:Array<Dynamic>, parent:Dynamic):Dynamic {
		var result = onCall(func, parameters == null ? [] : parameters, parent);
		return result;
	}

	public function onCall(func:String, parameters:Array<Dynamic>, parent:Dynamic):Dynamic {return null;}

	private function importFailedCallback(cl:Array<String>):Bool {
		var path = cl.join("/");

		var scr = Script.create(Paths.script('$folderlessPath$path', null, true));
		if (!(scr is DummyScript)) {
			// script is valid
			var cla = scr.getClass(cl.last());
			if (cla != null) {
				set(cl.last(), Script.createCustomClass(cla));
			} else {
				set(cl.last(), scr);
			}

			return true;
		}

		return false;
	}
}

class ScriptCustomClass implements IHScriptCustomConstructor {
	var scrClass:ScriptClass;
	var scrType:Class<IScriptClassInstance>;
	public function new(scrClass:ScriptClass, scrType:Class<IScriptClassInstance>) {
		this.scrClass = scrClass;
		this.scrType = scrType;
	}
	public function hnew(args:Array<Dynamic>):Dynamic {
		var a = [for(arg in args) arg];
		a.insert(0, scrClass);
		return Type.createInstance(scrType, a);
	}
}

interface IScriptClassInstance {

}