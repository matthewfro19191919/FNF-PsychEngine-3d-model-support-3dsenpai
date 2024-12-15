package;

import backend.animation.PsychAnimationController;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxNestedSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import haxe.macro.Type.AnonStatus;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import flixel.FlxG;
import openfl.display3D.Context3DTextureFormat;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Song;
import states.stages.objects.TankmenBG;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var vocals_file:String;
	@:optional var _editor_isPlayer:Null<Bool>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character3D extends FlxSprite
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

  public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
 
  public var canAutoAnim:Bool = true;
	public var canAutoIdle:Bool = true;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var missingCharacter:Bool = false;
	public var missingText:FlxText;
	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;

	// 3D
	public var modelView:ModelView;
	public var beganLoading:Bool = false;
	public var modelName:String = "";
	public var modelScale:Float = 1;
	public var model:ModelThing;
	public var initYaw:Float = 0;
	public var initPitch:Float = 0;
	public var initRoll:Float = 0;
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	public var zOffset:Float = 0;
	public var ambient:Float = 1;
	public var specular:Float = 1;
	public var diffuse:Float = 1;
	public var animSpeed:Map<String, Float> = new Map<String, Float>();
	public var noLoopList:Array<String> = [];
	public var geoMap:Map<String, String> = new Map<String, String>();
	public var atf:Bool = false;
	public var light:Bool = false;
	public var jointsPerVertex:Int = 4;

	public function new(x:Float, y:Float, modelView:ModelView, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		animOffsets = new Map<String, Array<Dynamic>>();
		this.isPlayer = isPlayer;
		changeCharacter(character);
		
		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
			case 'pico-blazin', 'darnell-blazin':
				skipDance = true;
		}

		curCharacter = character;
		this.isPlayer = isPlayer;

		var antialias = true;

		switch (curCharacter)
		{
			case 'bf':
				modelName = 'bf';
				modelScale = 1;
				animSpeed = ["default" => 1];
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				initYaw = 65;
				zOffset = 150;
				geoMap = [
					"singUP" => "singUP",
					"singRIGHT" => "singRIGHT",
					"singDOWN" => "singDOWN",
					"idle" => "default",
					"idleEnd" => "default",
					"singLEFT" => "singUP"
				];
				atf = true;
			case 'gf':
				modelName = 'gf';
				modelScale = 1;
				animSpeed = ["default" => 1];
				noLoopList = ["danceLEFT", "danceRIGHT"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				xOffset = -100;
				yOffset = -20;
				atf = true;
			case 'senpai':
				modelName = 'senpai';
				modelScale = 1;
				animSpeed = ["default" => 1];
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				initYaw = -65;
				zOffset = -150;
				yOffset = 70;
				geoMap = [
					"singUP" => "singUP",
					"singRIGHT" => "singRIGHT",
					"singDOWN" => "singDOWN",
					"singLEFT" => "singLEFT",
					"idle" => "default",
					"idleEnd" => "default"
				];
				antialias = false;
			case 'senpai-angry':
				modelName = 'senpai-angry';
				modelScale = 1;
				animSpeed = ["default" => 1];
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				initYaw = -65;
				zOffset = -150;
				yOffset = 70;
				geoMap = [
					"singUP" => "singUP",
					"singRIGHT" => "singRIGHT",
					"singDOWN" => "singDOWN",
					"singLEFT" => "singLEFT",
					"idle" => "default",
					"idleEnd" => "default"
				];
				antialias = false;
			case 'hydra':
				modelName = 'hydra';
				modelScale = 1;
				animSpeed = ["default" => 1];
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0.5;
				specular = 0.5;
				diffuse = 1;
				initYaw = 0;
				xOffset = -150;
				yOffset = 120;
				atf = true;
				light = true;
				jointsPerVertex = 1;
		}

		this.modelView = modelView;
		model = new ModelThing(modelView, modelName, 'awd', animSpeed, noLoopList, modelScale, initYaw, initPitch, initRoll, xOffset, yOffset, zOffset, false,
			antialias, atf, ambient, specular, light, jointsPerVertex);

		dance();
	}

	public function changeCharacter(character:String)
	{
		animationsArray = [];
		animOffsets = [];
		curCharacter = character;
		var characterPath:String = 'characters/$character.json';

		var path:String = Paths.getPath(characterPath, TEXT);
		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
		{
			path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
			missingCharacter = true;
			missingText = new FlxText(0, 0, 300, 'ERROR:\n$character.json', 16);
			missingText.alignment = CENTER;
		}

		try
		{
			#if MODS_ALLOWED
			loadCharacterFile(Json.parse(File.getContent(path)));
			#else
			loadCharacterFile(Json.parse(Assets.getText(path)));
			#end
		}
		catch(e:Dynamic)
		{
			trace('Error loading character file of "$character": $e');
		}

		skipDance = false;
		hasMissAnimations = hasAnimation('singLEFTmiss') || hasAnimation('singDOWNmiss') || hasAnimation('singUPmiss') || hasAnimation('singRIGHTmiss');
		recalculateDanceIdle();
		dance();
	}

	public function loadCharacterFile(json:Dynamic)
	{
		isAnimateAtlas = false;

		#if flxanimate
		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
			isAnimateAtlas = true;
		#end

		scale.set(1, 1);
		updateHitbox();

		if(!isAnimateAtlas)
		{
			frames = Paths.getMultiAtlas(json.image.split(','));
		}
		#if flxanimate
		else
		{
			atlas = new FlxAnimate();
			atlas.showPivot = false;
			try
			{
				Paths.loadAnimateAtlas(atlas, json.image);
			}
			catch(e:haxe.Exception)
			{
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
				trace(e.stack);
			}
		}
		#end

		imageFile = json.image;
		jsonScale = json.scale;
		if(json.scale != 1) {
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}

		// positioning
		positionArray = json.position;
		cameraPosition = json.camera_position;

		// data
		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file != null ? json.vocals_file : '';
		originalFlipX = (json.flip_x == true);
		editorIsPlayer = json._editor_isPlayer;

		// antialiasing
		noAntialiasing = (json.no_antialiasing == true);
		antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

		// animations
		animationsArray = json.animations;
		if(animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;

				if(!isAnimateAtlas)
				{
					if(animIndices != null && animIndices.length > 0)
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					else
						animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				#if flxanimate
				else
				{
					if(animIndices != null && animIndices.length > 0)
						atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					else
						atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
				}
				#end

				if(anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else addOffset(anim.anim, 0, 0);
			}
		}
		#if flxanimate
		if(isAnimateAtlas) copyAtlasValues();
		#end
		//trace('Loaded file to character ' + curCharacter);
	}

	override function update(elapsed:Float)
	{
		if (model == null || !model.fullyLoaded)
			return;

		if (PlayState.instance.endingSong)
			return;

		if (model != null && model.fullyLoaded && modelView != null)
		{
			model.update();
		}

		if (!isPlayer)
		{
			if (getCurAnim().startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				idleEnd();
				holdTimer = 0;
			}
		}
		if(isAnimateAtlas) atlas.update(elapsed);

		if(debugMode || (!isAnimateAtlas && animation.curAnim == null) || (isAnimateAtlas && (atlas.anim.curInstance == null || atlas.anim.curSymbol == null)))
		{
			super.update(elapsed);
			return;
		}

		if(heyTimer > 0)
		{
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;
			if(heyTimer <= 0)
			{
				var anim:String = getAnimationName();
				if(specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
        }
		switch(curCharacter)
		{
			case 'pico-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;

					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if(isAnimationFinished()) playAnim(getAnimationName(), false, false, animation.curAnim.frames.length - 3);
		}

		if (getAnimationName().startsWith('sing')) holdTimer += elapsed;
		else if(isPlayer) holdTimer = 0;

		if (!isPlayer && holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();
		if(isAnimationFinished() && hasAnimation('$name-loop'))
			playAnim('$name-loop');

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool
	{
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curInstance == null || atlas.anim.curSymbol == null);
	}


	var _lastPlayedAnimation:String;
	inline public function getAnimationName():String
	{
		return _lastPlayedAnimation;
	}

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
	}

	public function finishAnimation():Void
	{
		if(isAnimationNull()) return;

		if(!isAnimateAtlas) animation.curAnim.finish();
		else atlas.anim.curFrame = atlas.anim.length - 1;
	}

	public function hasAnimation(anim:String):Bool
	{
		return animOffsets.exists(anim);
	}

	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.isPlaying;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		if(!isAnimateAtlas) animation.curAnim.paused = value;
		else
		{
			if(value) atlas.pauseAnimation();
			else atlas.resumeAnimation();
		}

		return value;
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?ignoreDebug:Bool = false)
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(hasAnimation('idle' + idleSuffix))
				playAnim('idle' + idleSuffix);
		}

		if (PlayState.instance.endingSong)
			return;

		if (!model.fullyLoaded)
			return;

		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel':
					if (!getCurAnim().startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRIGHT', true);
						else
							playAnim('danceLEFT', true);
					}
				default:
					if (holdTimer == 0)
					{
						if (model == null)
						{
							trace("NO DANCE - NO MODEL");
							return;
						}
						if (!model.fullyLoaded)
						{
							trace("NO DANCE - NO FULLY LOAD");
							return;
						}
						if (!noLoopList.contains('idle'))
							return;
						playAnim('idle', true);
					}
			}
		}
		else if (holdTimer == 0)
		{
			if (model == null)
			{
				trace("NO DANCE - NO MODEL");
				return;
			}
			if (!model.fullyLoaded)
			{
				trace("NO DANCE - NO FULLY LOAD");
				return;
			}
			if (!noLoopList.contains('idle'))
				return;
			playAnim('idle', true);
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (PlayState.instance.endingSong)
			return;

		if (!model.fullyLoaded)
			return;

		if ((!debugMode || ignoreDebug))
		{
			if (animExists(getCurAnim() + "End"))
				playAnim(getCurAnim() + "End", true, false);
			else if (animExists('idleEnd'))
				playAnim('idleEnd', true, false);
			else
				playAnim('idle', true);
		}
	}

	var curAtlasAnim:String;

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		if(!isAnimateAtlas)
		{
			animation.play(AnimName, Force, Reversed, Frame);
		}
		else
		{
			atlas.anim.play(AnimName, Force, Reversed, Frame);
			atlas.update(0);
		}
		_lastPlayedAnimation = AnimName;

		if (hasAnimation(AnimName))
		{
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0], daOffset[1]);
		}
		//else offset.set(0, 0);

		if (curCharacter.startsWith('gf-') || curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;

			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
		if (PlayState.instance.endingSong)
			return;

		if (!model.fullyLoaded)
			return;

		if (AnimName.endsWith('-alt') && !animExists(AnimName))
		{
			AnimName = AnimName.substring(0, AnimName.length - 4);
		}

		if (AnimName.contains('sing'))
			canAutoIdle = true;

		var geo:String = "";
		if (geoMap[AnimName] != null)
			geo = geoMap[AnimName];

		if (AnimName.endsWith('miss'))
		{
			if (!animExists(AnimName))
				AnimName = AnimName.substring(0, AnimName.length - 4);
			geo = "miss";
			model.modelMaterial.colorTransform.redMultiplier = 0.2;
			model.modelMaterial.colorTransform.greenMultiplier = 0.2;
			model.modelMaterial.colorTransform.blueMultiplier = 0.75;
		}
		else
		{
			model.modelMaterial.colorTransform.redMultiplier = 1;
			model.modelMaterial.colorTransform.greenMultiplier = 1;
			model.modelMaterial.colorTransform.blueMultiplier = 1;
		}

		if (model != null && model.fullyLoaded)
		{
			model.playAnim(AnimName, Force, Frame, geo);
		}
	}

	function loadMappedAnims():Void
	{
		try
		{
			var songData:SwagSong = Song.getChart('picospeaker', Paths.formatToSongPath(Song.loadedSongName));
			if(songData != null)
				for (section in songData.notes)
					for (songNotes in section.sectionNotes)
						animationNotes.push(songNotes);

			TankmenBG.animationNotes = animationNotes;
			animationNotes.sort(sortAnims);
		}
		catch(e:Dynamic) {}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (hasAnimation('danceLeft' + idleSuffix) && hasAnimation('danceRight' + idleSuffix));

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	// Atlas support
	// special thanks ne_eo for the references, you're the goat!!
	@:allow(states.editors.CharacterEditorState)
	public var isAnimateAtlas(default, null):Bool = false;
	#if flxanimate
	public var atlas:FlxAnimate;
	public override function draw()
	{
		var lastAlpha:Float = alpha;
		var lastColor:FlxColor = color;
		if(missingCharacter)
		{
			alpha *= 0.6;
			color = FlxColor.BLACK;
		}

		if(isAnimateAtlas)
		{
			if(atlas.anim.curInstance != null)
			{
				copyAtlasValues();
				atlas.draw();
				alpha = lastAlpha;
				color = lastColor;
				if(missingCharacter && visible)
				{
					missingText.x = getMidpoint().x - 150;
					missingText.y = getMidpoint().y - 10;
					missingText.draw();
				}
			}
			return;
		}
		super.draw();
		if(missingCharacter && visible)
		{
			alpha = lastAlpha;
			color = lastColor;
			missingText.x = getMidpoint().x - 150;
			missingText.y = getMidpoint().y - 10;
			missingText.draw();
		}
	}

	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}

	public override function destroy()
	{
		atlas = FlxDestroyUtil.destroy(atlas);
		super.destroy();
	}
	#end
	public function getCurAnim()
	{
		if (model != null && model.fullyLoaded)
			return model.currentAnim;
		else
			return "";
	}

	public function animExists(anim:String)
	{
		if (model != null && model.fullyLoaded)
			return model.animationSetSkeleton.hasAnimation(anim);
		else
			return false;
	}

	override public function destroy()
	{
		if (model != null)
			model.destroy();
		model = null;
		modelView = null;
		if (animSpeed != null)
		{
			animSpeed.clear();
			animSpeed = null;
		}
		super.destroy();
	}
}
