package states.stages;

import flixel.math.FlxAngle;
import sys.io.File;
import lime.ui.FileDialog;
import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import away3d.textfield.RectangleBitmapTexture;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BlurFilter;
import openfl.filters.ShaderFilter;
import away3d.primitives.PlaneGeometry;
import transition.CustomTransition;
import lime.app.Application;
import openfl.display3D.textures.TextureBase;
import lime.graphics.OpenGLRenderContext;
import openfl.display3D.textures.Texture;
import flixel.graphics.FlxGraphic;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import away3d.core.base.ParticleGeometry;
import away3d.loaders.parsers.AWDParser;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import flixel.FlxState;
import away3d.textures.BitmapCubeTexture;
import away3d.textures.BitmapTexture;
import away3d.primitives.SkyBox;
import away3d.materials.MaterialBase;
import openfl.geom.Vector3D;
import away3d.animators.data.ParticleProperties;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.materials.ColorMaterial;
import away3d.tools.helpers.ParticleGeometryHelper;
import away3d.animators.ParticleAnimator;
import away3d.animators.nodes.ParticleRotationalVelocityNode;
import away3d.animators.nodes.ParticleRotateToPositionNode;
import away3d.animators.nodes.ParticleVelocityNode;
import away3d.animators.nodes.ParticlePositionNode;
import away3d.animators.ParticleAnimationSet;
import openfl.Vector;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;
import away3d.utils.Cast;
import away3d.materials.TextureMaterial;
import away3d.library.assets.Asset3DType;
import openfl.net.URLRequest;
import away3d.events.Asset3DEvent;
import away3d.library.Asset3DLibrary;
#if sys
import sys.FileSystem;
#end
import flixel.math.FlxRect;
import openfl.system.System;
import openfl.ui.KeyLocation;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
// import polymod.fs.SysFileSystem;
import Section.SwagSection;
import backend.Song.SwagSong;
import backend.Song.SongEvents;
// import shaders.WiggleEffect.WiggleEffectType;
// import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
// import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
// import flixel.FlxState;
import flixel.FlxSubState;
// import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
// import flixel.addons.effects.FlxTrailArea;
// import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
// import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
// import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
// import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
// import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import states.stages.objects.*;
import substates.GameOverSubstate;
import cutscenes.DialogueBox;

import openfl.utils.Assets as OpenFlAssets;

class TVStage extends BaseStage
{
	var schoolPlane:Mesh;
	var planeBitmap:BitmapTexture;
	var planeMat:TextureMaterial;
	var petal:Geometry;
	var geometrySet:Vector<Geometry>;
	var particleGeo:ParticleGeometry;
	var particleSet:ParticleAnimationSet;
	var particleAnimator:ParticleAnimator;
	var particleMat:ColorMaterial;
	var particleMesh:Mesh;
	var skybox:SkyBox;
	var skyboxTex:BitmapCubeTexture;

	var view:ModelView;

	var tv:TVModel;

	var lowRes:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camNotes:FlxCamera;
	public var camUnderHUD:FlxCamera;
	public var camOverlay:FlxCamera;

	// var tex:Texture;
	var posMap:Map<String, PosThing> = [];

	override function create()
	{

			view = new ModelView(1, 1, 1, 1, 6000);

			view.view.visible = false;

			view.view.width = FlxG.scaleMode.gameSize.x;
			view.view.height = FlxG.scaleMode.gameSize.y;
			view.view.x = FlxG.stage.stageWidth / 2 - FlxG.scaleMode.gameSize.x / 2;
			view.view.y = FlxG.stage.stageHeight / 2 - FlxG.scaleMode.gameSize.y / 2;

			view.distance = 1;
			view.setCamLookAt(0, 90, 0);
			view.view.camera.x = view.view.camera.y = view.view.camera.z = 0;
			Asset3DLibrary.enableParser(AWDParser);
			Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteTV);
			Asset3DLibrary.load(new URLRequest("assets/models/floor/floor.awd"));
			// Asset3DLibrary.load(new URLRequest("assets/models/petal.awd"));

			planeBitmap = Cast.bitmapTexture("assets/models/floor/floor.png");
			planeMat = new TextureMaterial(planeBitmap, false, true);
			schoolPlane = new Mesh(new PlaneGeometry(5000, 5000), planeMat);
			schoolPlane.scale(70);
			schoolPlane.y -= 8000;

			view.view.scene.addChild(schoolPlane);

			skyboxTex = new BitmapCubeTexture(Cast.bitmapData("assets/models/skybox2/px.png"), Cast.bitmapData("assets/models/skybox2/nx.png"),
				Cast.bitmapData("assets/models/skybox2/py.png"), Cast.bitmapData("assets/models/skybox2/ny.png"),
				Cast.bitmapData("assets/models/skybox2/pz.png"), Cast.bitmapData("assets/models/skybox2/nz.png"));

			skybox = new SkyBox(skyboxTex);
			view.view.scene.addChild(skybox);

			// tv = new ModelThing(view, 'tv', 'awd', [], [], 50, 0, 0, 0, -50, -20, 0, false, false);

			camNotes.bgColor.alpha = 255;
			// camNotes.setPosition(FlxG.width - 1, FlxG.height - 1);

			// camNotes.setFilters([new ShaderFilter(new Scanlines())]);
			@:privateAccess
			if (true)
			{
				camNotes.flashSprite.cacheAsBitmap = true;
			}

			@:privateAccess
			tv = new TVModel(planeBitmap.bitmapData.__texture, view, 'tv', 'awd', [], [], 50, 0, 0, 0, -50, 2000, 0, false, false, true);
	}

	private function onAssetComplete(event:Asset3DEvent):Void
	{
		if (event.asset.assetType == Asset3DType.MESH)
		{
			if (event.asset.name == 'Weeb_School_mesh')
			{
				planeBitmap = Cast.bitmapTexture("assets/models/school.png");
				planeMat = new TextureMaterial(planeBitmap, false, false);
				planeMat.alphaThreshold = 0.85;
				schoolPlane = cast event.asset;
				schoolPlane.material = planeMat;
				planeMat.shadowMethod = view.shadowMapMethod;
				schoolPlane.castsShadows = true;
				schoolPlane.scale(70);
				view.view.scene.addChild(schoolPlane);
				schoolPlane.yaw(270);
				schoolPlane.x = 750;
				schoolPlane.y = -30;
				System.gc();
				LoadingCount.increment();
			}
		}
		if (event.asset.assetType == Asset3DType.GEOMETRY)
		{
			if (StringTools.startsWith(event.asset.name, 'petal'))
			{
				petal = cast event.asset;
				petal.scale(100);
				geometrySet = new Vector<Geometry>();
				for (i in 0...400)
				{
					geometrySet.push(petal);
				}
				particleSet = new ParticleAnimationSet(true, true);
				particleSet.initParticleFunc = initParticleFunc;
				particleSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
				particleSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
				particleSet.addAnimation(new ParticleRotateToPositionNode(ParticlePropertiesMode.LOCAL_STATIC));
				particleSet.addAnimation(new ParticleRotationalVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));

				particleAnimator = new ParticleAnimator(particleSet);
				particleMat = new ColorMaterial(0xff70cf);
				particleGeo = ParticleGeometryHelper.generateGeometry(geometrySet);
				particleMesh = new Mesh(particleGeo, particleMat);
				particleMesh.animator = particleAnimator;
				view.view.scene.addChild(particleMesh);
				System.gc();
				particleAnimator.start();
				LoadingCount.increment();
			}
		}
	}

	private function onAssetCompleteTV(event:Asset3DEvent):Void
	{
		if (event.asset.assetType == Asset3DType.MESH)
		{
			if (event.asset.name == 'floor_mesh')
			{
				planeBitmap = Cast.bitmapTexture("assets/models/floor/floor.png");
				planeMat = new TextureMaterial(planeBitmap, false, true);
				schoolPlane = cast event.asset;
				schoolPlane.material = planeMat;
				planeMat.shadowMethod = view.shadowMapMethod;
				schoolPlane.scale(70);
				schoolPlane.geometry.scaleUV(5, 5);
				view.view.scene.addChild(schoolPlane);
				schoolPlane.x = 750;
				schoolPlane.y = -90;
				System.gc();
				LoadingCount.increment();
			}
		}
	}

	private function initParticleFunc(prop:ParticleProperties):Void
	{
		prop.startTime = Math.random() * 5 - 5;
		prop.duration = 5;

		var x = Math.random() * 20 - 10;
		var z = Math.random() * 20 - 10;
		var y = -Math.random() * 70 - 30;
		prop.nodes[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(x, y, z);

		var posX = Math.random() * 1000 - 500;
		var posZ = Math.random() * 1000 - 500;
		prop.nodes[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(posX, 400, posZ);

		var randAngle = Math.random() * 359;
		prop.nodes[ParticleRotationalVelocityNode.ROTATIONALVELOCITY_VECTOR3D] = new Vector3D(Math.random() * 40 - 20, Math.random() * 40 - 20,
			Math.random() * 40 - 20, randAngle);

		prop.nodes[ParticleRotateToPositionNode.POSITION_VECTOR3D] = new Vector3D(Math.random() * 40 - 20, Math.random() * 40 - 20, Math.random() * 40 - 20);
	}
}
