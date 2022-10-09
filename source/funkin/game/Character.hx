package funkin.game;

import flixel.math.FlxPoint;
import funkin.interfaces.IBeatReceiver;
import funkin.interfaces.IOffsetCompatible;
import funkin.system.XMLUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;

import openfl.utils.Assets;
import haxe.xml.Access;
import haxe.Exception;
import funkin.system.Conductor;

using StringTools;

class Character extends FlxSprite implements IBeatReceiver implements IOffsetCompatible
{
	private var __stunnedTime:Float = 0;
	public var stunned(default, set):Bool = false;

	private function set_stunned(b:Bool) {
		__stunnedTime = 0;
		return stunned = b;
	}

	public var animOffsets:Map<String, FlxPoint>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var isGF:Bool = false;
	public var curCharacter:String = 'bf';

	public var lastHit:Float = -5000;
	public var dadVar:Float = 4;

	public var playerOffsets:Bool = false;

	public var icon:String = null;

	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);
	public var globalOffset:FlxPoint = new FlxPoint(0, 0);

	public inline function getCameraPosition() {
		var midpoint = getMidpoint();
		return FlxPoint.get(
			midpoint.x + (isPlayer ? -100 : 150) + globalOffset.x + cameraOffset.x,
			midpoint.y - 100 + globalOffset.y + cameraOffset.y);
	}
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, FlxPoint>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		while(true) {
			switch (curCharacter)
			{
				// case 'your-char': // To hardcode characters
				default:
					// load xml
					if (!Assets.exists(Paths.xml('characters/$curCharacter'))) {
						curCharacter = "bf";
						continue;
					}

					var plainXML = Assets.getText(Paths.xml('characters/$curCharacter'));
					var character:Access;
					try {
						var charXML = Xml.parse(plainXML).firstElement();
						if (charXML == null) throw new Exception("Missing \"character\" node in XML.");
						character = new Access(charXML);
					} catch(e) {
						trace(e);
						curCharacter = "bf";
						continue;
					}

					if (character.has.isPlayer) playerOffsets = (character.att.isPlayer == "true");
					if (character.has.isGF) isGF = (character.att.isGF == "true");
					if (character.has.x) globalOffset.x = Std.parseFloat(character.att.x);
					if (character.has.y) globalOffset.y = Std.parseFloat(character.att.y);
					if (character.has.camx) cameraOffset.x = Std.parseFloat(character.att.camx);
					if (character.has.camy) cameraOffset.y = Std.parseFloat(character.att.camy);
					if (character.has.flipX) flipX = (character.att.flipX == "true");
					if (character.has.icon) icon = character.att.icon;

					frames = Paths.getSparrowAtlas('characters/$curCharacter');
					for(anim in character.nodes.anim) {
						XMLUtil.addXMLAnimation(this, anim);
					}
			}
			break;
		}
		// 	case 'gf':
		// 		// GIRLFRIEND CODE
		// 		tex = Paths.getSparrowAtlas('GF_assets');
		// 		frames = tex;
		// 		animation.addByPrefix('cheer', 'GF Cheer', 24, false);
		// 		animation.addByPrefix('singLEFT', 'GF left note', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
		// 		animation.addByPrefix('singUP', 'GF Up Note', 24, false);
		// 		animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
		// 		animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
		// 		animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// 		animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		// 		animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
		// 		animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
		// 		animation.addByPrefix('scared', 'GF FEAR', 24);

		// 		addOffset('cheer');
		// 		addOffset('sad', -2, -2);
		// 		addOffset('danceLeft', 0, -9);
		// 		addOffset('danceRight', 0, -9);

		// 		addOffset("singUP", 0, 4);
		// 		addOffset("singRIGHT", 0, -20);
		// 		addOffset("singLEFT", 0, -19);
		// 		addOffset("singDOWN", 0, -20);
		// 		addOffset('hairBlow', 45, -8);
		// 		addOffset('hairFall', 0, -9);

		// 		addOffset('scared', -2, -17);

		// 		playAnim('danceRight');

		// 	case 'gf-christmas':
		// 		tex = Paths.getSparrowAtlas('christmas/gfChristmas');
		// 		frames = tex;
		// 		animation.addByPrefix('cheer', 'GF Cheer', 24, false);
		// 		animation.addByPrefix('singLEFT', 'GF left note', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
		// 		animation.addByPrefix('singUP', 'GF Up Note', 24, false);
		// 		animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
		// 		animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
		// 		animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// 		animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		// 		animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
		// 		animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
		// 		animation.addByPrefix('scared', 'GF FEAR', 24);

		// 		addOffset('cheer');
		// 		addOffset('sad', -2, -2);
		// 		addOffset('danceLeft', 0, -9);
		// 		addOffset('danceRight', 0, -9);

		// 		addOffset("singUP", 0, 4);
		// 		addOffset("singRIGHT", 0, -20);
		// 		addOffset("singLEFT", 0, -19);
		// 		addOffset("singDOWN", 0, -20);
		// 		addOffset('hairBlow', 45, -8);
		// 		addOffset('hairFall', 0, -9);

		// 		addOffset('scared', -2, -17);

		// 		playAnim('danceRight');

		// 	case 'gf-car':
		// 		tex = Paths.getSparrowAtlas('gfCar');
		// 		frames = tex;
		// 		animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
		// 		animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// 		animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
		// 			false);

		// 		addOffset('danceLeft', 0);
		// 		addOffset('danceRight', 0);

		// 		playAnim('danceRight');

		// 	case 'gf-pixel':
		// 		tex = Paths.getSparrowAtlas('weeb/gfPixel');
		// 		frames = tex;
		// 		animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
		// 		animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// 		animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		// 		addOffset('danceLeft', 0);
		// 		addOffset('danceRight', 0);

		// 		playAnim('danceRight');

		// 		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		// 		updateHitbox();
		// 		antialiasing = false;

		// 	case 'dad':
		// 		// DAD ANIMATION LOADING CODE
		// 		tex = Paths.getSparrowAtlas('DADDY_DEAREST');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'Dad idle dance', 24);
		// 		animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
		// 		animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
		// 		animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
		// 		animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

		// 		addOffset('idle');
		// 		addOffset("singUP", -6, 50);
		// 		addOffset("singRIGHT", 0, 27);
		// 		addOffset("singLEFT", -10, 10);
		// 		addOffset("singDOWN", 0, -30);

		// 		dadVar = 6.1;

		// 		playAnim('idle');
		// 	case 'spooky':
		// 		tex = Paths.getSparrowAtlas('spooky_kids_assets');
		// 		frames = tex;
		// 		animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
		// 		animation.addByPrefix('singLEFT', 'note sing left', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
		// 		animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
		// 		animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

		// 		addOffset('danceLeft');
		// 		addOffset('danceRight');

		// 		addOffset("singUP", -20, 26);
		// 		addOffset("singRIGHT", -130, -14);
		// 		addOffset("singLEFT", 130, -10);
		// 		addOffset("singDOWN", -50, -130);

		// 		playAnim('danceRight');
		// 	case 'mom':
		// 		tex = Paths.getSparrowAtlas('Mom_Assets');
		// 		frames = tex;

		// 		animation.addByPrefix('idle', "Mom Idle", 24, false);
		// 		animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
		// 		animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
		// 		animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
		// 		// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
		// 		// CUZ DAVE IS DUMB!
		// 		animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 14, 71);
		// 		addOffset("singRIGHT", 10, -60);
		// 		addOffset("singLEFT", 250, -23);
		// 		addOffset("singDOWN", 20, -160);

		// 		playAnim('idle');

		// 	case 'mom-car':
		// 		tex = Paths.getSparrowAtlas('momCar');
		// 		frames = tex;

		// 		animation.addByPrefix('idle', "Mom Idle", 24, false);
		// 		animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
		// 		animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
		// 		animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
		// 		// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
		// 		// CUZ DAVE IS DUMB!
		// 		animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 14, 71);
		// 		addOffset("singRIGHT", 10, -60);
		// 		addOffset("singLEFT", 250, -23);
		// 		addOffset("singDOWN", 20, -160);

		// 		playAnim('idle');
		// 	case 'monster':
		// 		tex = Paths.getSparrowAtlas('Monster_Assets');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'monster idle', 24, false);
		// 		animation.addByPrefix('singUP', 'monster up note', 24, false);
		// 		animation.addByPrefix('singDOWN', 'monster down', 24, false);
		// 		animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", -20, 50);
		// 		addOffset("singRIGHT", -51);
		// 		addOffset("singLEFT", -30);
		// 		addOffset("singDOWN", -30, -40);
		// 		playAnim('idle');
		// 	case 'monster-christmas':
		// 		tex = Paths.getSparrowAtlas('christmas/monsterChristmas');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'monster idle', 24, false);
		// 		animation.addByPrefix('singUP', 'monster up note', 24, false);
		// 		animation.addByPrefix('singDOWN', 'monster down', 24, false);
		// 		animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", -20, 50);
		// 		addOffset("singRIGHT", -51);
		// 		addOffset("singLEFT", -30);
		// 		addOffset("singDOWN", -40, -94);
		// 		playAnim('idle');
		// 	case 'pico':
		// 		tex = Paths.getSparrowAtlas('Pico_FNF_assetss');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', "Pico Idle Dance", 24);
		// 		animation.addByPrefix('singUP', 'pico Up note0', 24, false);
		// 		animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
		// 		if (isPlayer)
		// 		{
		// 			animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
		// 			animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
		// 			animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
		// 			animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
		// 		}
		// 		else
		// 		{
		// 			// Need to be flipped! REDO THIS LATER!
		// 			animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
		// 			animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
		// 			animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
		// 			animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
		// 		}

		// 		animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
		// 		animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

		// 		addOffset('idle');
		// 		addOffset("singUP", -29, 27);
		// 		addOffset("singRIGHT", -68, -7);
		// 		addOffset("singLEFT", 65, 9);
		// 		addOffset("singDOWN", 200, -70);
		// 		addOffset("singUPmiss", -19, 67);
		// 		addOffset("singRIGHTmiss", -60, 41);
		// 		addOffset("singLEFTmiss", 62, 64);
		// 		addOffset("singDOWNmiss", 210, -28);

		// 		playAnim('idle');

		// 		flipX = true;


		// 	case 'bf-christmas':
		// 		var tex = Paths.getSparrowAtlas('christmas/bfChristmas');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		// 		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		// 		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		// 		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		// 		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		// 		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		// 		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		// 		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		// 		animation.addByPrefix('hey', 'BF HEY', 24, false);

		// 		addOffset('idle', -5);
		// 		addOffset("singUP", -29, 27);
		// 		addOffset("singRIGHT", -38, -7);
		// 		addOffset("singLEFT", 12, -6);
		// 		addOffset("singDOWN", -10, -50);
		// 		addOffset("singUPmiss", -29, 27);
		// 		addOffset("singRIGHTmiss", -30, 21);
		// 		addOffset("singLEFTmiss", 12, 24);
		// 		addOffset("singDOWNmiss", -11, -19);
		// 		addOffset("hey", 7, 4);

		// 		playAnim('idle');

		// 		flipX = true;
		// 	case 'bf-car':
		// 		var tex = Paths.getSparrowAtlas('bfCar');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		// 		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		// 		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		// 		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		// 		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		// 		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		// 		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		// 		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

		// 		addOffset('idle', -5);
		// 		addOffset("singUP", -29, 27);
		// 		addOffset("singRIGHT", -38, -7);
		// 		addOffset("singLEFT", 12, -6);
		// 		addOffset("singDOWN", -10, -50);
		// 		addOffset("singUPmiss", -29, 27);
		// 		addOffset("singRIGHTmiss", -30, 21);
		// 		addOffset("singLEFTmiss", 12, 24);
		// 		addOffset("singDOWNmiss", -11, -19);
		// 		playAnim('idle');

		// 		flipX = true;
		// 	case 'bf-pixel':
		// 		frames = Paths.getSparrowAtlas('weeb/bfPixel');
		// 		animation.addByPrefix('idle', 'BF IDLE', 24, false);
		// 		animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
		// 		animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
		// 		animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
		// 		animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
		// 		animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP");
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT");
		// 		addOffset("singDOWN");
		// 		addOffset("singUPmiss");
		// 		addOffset("singRIGHTmiss");
		// 		addOffset("singLEFTmiss");
		// 		addOffset("singDOWNmiss");

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		playAnim('idle');

		// 		width -= 100;
		// 		height -= 100;

		// 		antialiasing = false;

		// 		flipX = true;
		// 	case 'bf-pixel-dead':
		// 		frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD');
		// 		animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
		// 		animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
		// 		animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
		// 		animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
		// 		animation.play('firstDeath');

		// 		addOffset('firstDeath');
		// 		addOffset('deathLoop', -37);
		// 		addOffset('deathConfirm', -37);
		// 		playAnim('firstDeath');
		// 		// pixel bullshit
		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();
		// 		antialiasing = false;
		// 		flipX = true;

		// 	case 'senpai':
		// 		frames = Paths.getSparrowAtlas('weeb/senpai');
		// 		animation.addByPrefix('idle', 'Senpai Idle', 24, false);
		// 		animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 5, 37);
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT", 40);
		// 		addOffset("singDOWN", 14);

		// 		playAnim('idle');

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		antialiasing = false;
		// 	case 'senpai-angry':
		// 		frames = Paths.getSparrowAtlas('weeb/senpai');
		// 		animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
		// 		animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 5, 37);
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT", 40);
		// 		addOffset("singDOWN", 14);
		// 		playAnim('idle');

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		antialiasing = false;

		// 	case 'spirit':
		// 		frames = Paths.getPackerAtlas('weeb/spirit');
		// 		animation.addByPrefix('idle', "idle spirit_", 24, false);
		// 		animation.addByPrefix('singUP', "up_", 24, false);
		// 		animation.addByPrefix('singRIGHT', "right_", 24, false);
		// 		animation.addByPrefix('singLEFT', "left_", 24, false);
		// 		animation.addByPrefix('singDOWN', "spirit down_", 24, false);

		// 		addOffset('idle', -220, -280);
		// 		addOffset('singUP', -220, -240);
		// 		addOffset("singRIGHT", -220, -280);
		// 		addOffset("singLEFT", -200, -280);
		// 		addOffset("singDOWN", 170, 110);

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		playAnim('idle');

		// 		antialiasing = false;

		// 	case 'parents-christmas':
		// 		frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets');
		// 		animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
		// 		animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
		// 		animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
		// 		animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

		// 		animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

		// 		animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
		// 		animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
		// 		animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", -47, 24);
		// 		addOffset("singRIGHT", -1, -23);
		// 		addOffset("singLEFT", -30, 16);
		// 		addOffset("singDOWN", -31, -29);
		// 		addOffset("singUP-alt", -47, 24);
		// 		addOffset("singRIGHT-alt", -1, -24);
		// 		addOffset("singLEFT-alt", -30, 15);
		// 		addOffset("singDOWN-alt", -30, -27);

		// 		playAnim('idle');
				
		// 	default:
		// 		curCharacter = "bf";
		// 		var tex = Paths.getSparrowAtlas('BOYFRIEND');
		// 		frames = tex;
		// 		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		// 		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		// 		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		// 		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		// 		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		// 		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		// 		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		// 		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		// 		animation.addByPrefix('hey', 'BF HEY', 24, false);

		// 		animation.addByPrefix('firstDeath', "BF dies", 24, false);
		// 		animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
		// 		animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

		// 		animation.addByPrefix('scared', 'BF idle shaking', 24);

		// 		addOffset('idle', -5);
		// 		addOffset("singUP", -29, 27);
		// 		addOffset("singRIGHT", -38, -7);
		// 		addOffset("singLEFT", 12, -6);
		// 		addOffset("singDOWN", -10, -50);
		// 		addOffset("singUPmiss", -29, 27);
		// 		addOffset("singRIGHTmiss", -30, 21);
		// 		addOffset("singLEFTmiss", 12, 24);
		// 		addOffset("singDOWNmiss", -11, -19);
		// 		addOffset("hey", 7, 4);
		// 		addOffset('firstDeath', 37, 11);
		// 		addOffset('deathLoop', 37, 5);
		// 		addOffset('deathConfirm', 37, 69);
		// 		addOffset('scared', -4);

		// 		playAnim('idle');

		// 		flipX = true;
		// }

		dance();


		isDanceLeftDanceRight = (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null);
		
		// alternative to xor operator
		// for people who dont believe it, heres the truth table
		// [   a   ][   b   ][ a!= b ]
		// [ true  ][ true  ][ false ]
		// [ true  ][ false ][ true  ]
		// [ false ][ true  ][ true  ]
		// [ true  ][ true  ][ false ]
		if (isPlayer != playerOffsets)
		{
			// character is flipped
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));
			
			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		if (isPlayer) flipX = !flipX;
	}

	var isDanceLeftDanceRight:Bool = false;

	public function switchOffset(anim1:String, anim2:String) {
		var old = animOffsets[anim1];
		animOffsets[anim1] = animOffsets[anim2];
		animOffsets[anim2] = old;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (stunned) {
			__stunnedTime += elapsed;
			if (__stunnedTime > 5 / 60)
				stunned = false;
		}
	}

	private var danced:Bool = false;
	
	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				// hardcode custom dance animations here
				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					if (isDanceLeftDanceRight) {
						playAnim((danced = !danced) ? 'danceLeft' : 'danceRight');
					} else
						playAnim('idle');
			}
		}
	}

	public function beatHit(curBeat:Int) {
		if ((lastHit + (Conductor.stepCrochet * dadVar) < Conductor.songPosition) || animation.curAnim == null || (!animation.curAnim.name.startsWith("sing") && animation.curAnim.finished))
			dance();
	}
	public function stepHit(curStep:Int) {
		// nothing
	}

	var __reverseDrawProcedure:Bool = false;
	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__reverseDrawProcedure) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}
	
	public override function draw() {
		if (flipX) {
			__reverseDrawProcedure = true;

			flipX = false;
			scale.x *= -1;
			super.draw();
			flipX = true;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		} else
			super.draw();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (daOffset != null)
			offset.set(daOffset.x * (isPlayer != playerOffsets ? -1 : 1), daOffset.y);
		else
			offset.set(0, 0);

		offset.x += globalOffset.x * (isPlayer != playerOffsets ? 1 : -1);
		offset.y -= globalOffset.y;

		if (AnimName.startsWith("sing"))
			lastHit = Conductor.songPosition;
		
		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public override function destroy() {
		super.destroy();
	}

	public inline function getIcon() {
		return (icon != null) ? icon : curCharacter;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = new FlxPoint(x, y);
	}
}