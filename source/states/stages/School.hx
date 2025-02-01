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

class School extends BaseStage
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

	// var tex:Texture;
	var posMap:Map<String, PosThing> = [];
	var bgGirls:BackgroundGirls;
	override function create()
	{
		view = new ModelView(1, 0, 1, 1, 6000);

			view.view.visible = false;

			LoadingCount.expand(2);

			view.distance = 370;
			view.setCamLookAt(0, 90, 0);

			Asset3DLibrary.enableParser(AWDParser);
			Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
			Asset3DLibrary.load(new URLRequest("assets/models/school.awd"));
			Asset3DLibrary.load(new URLRequest("assets/models/petal.awd"));

			skyboxTex = new BitmapCubeTexture(Cast.bitmapData("assets/models/skybox/px.png"), Cast.bitmapData("assets/models/skybox/nx.png"),
				Cast.bitmapData("assets/models/skybox/py.png"), Cast.bitmapData("assets/models/skybox/ny.png"),
				Cast.bitmapData("assets/models/skybox/pz.png"), Cast.bitmapData("assets/models/skybox/nz.png"));

			skybox = new SkyBox(skyboxTex);
			view.view.scene.addChild(skybox);
			view.view.width = FlxG.scaleMode.gameSize.x;
			view.view.height = FlxG.scaleMode.gameSize.y;
			view.view.x = FlxG.stage.stageWidth / 2 - FlxG.scaleMode.gameSize.x / 2;
			view.view.y = FlxG.stage.stageHeight / 2 - FlxG.scaleMode.gameSize.y / 2;
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
