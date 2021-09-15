package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

#if windows
import Sys;
import sys.FileSystem;
#end


using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var introstart:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var pico:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var shadersLoaded:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";



	private var chromOn:Bool = false;
	private var radialBlurOn:Bool = false;




	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	var filters:Array<BitmapFilter> = [];
	var camfilters:Array<BitmapFilter> = [];
	private var combo:Int = 0;
	private var misses:Int = 0;
	var totalAccuracy:Float = 0;
	var totalRank:String = "S+";
	var songNotesHit:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camHUD2:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var deathCounter:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;


	var ch = 2 / 1000;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	var stageCurtains:FlxSprite;
	var bgPloosh:FlxSprite;
	var bg:FlxSprite;
	var stageLights:FlxSprite;
	var skyBG:FlxSprite;
	var bgLimo:FlxSprite;
	var dancer:BackgroundDancer;
	var overlayShit:FlxSprite;
	var gfstageCurtains:FlxSprite;
	var gfstageFront:FlxSprite;
	var stagebg:FlxSprite;
	var dancer1:BackgroundDancer;
	var dancer2:BackgroundDancer;
	var dancerlimo2:BackgroundDancer;
	var dancerlimo3:BackgroundDancer;
	var dancerlimo1:BackgroundDancer;
	var dancerlimo4:BackgroundDancer;
	var dancerlimo5:BackgroundDancer;
	var picosing:Bool = false;
	var center:Bool = false;
	var center2:Bool = false;
	var bfsing:Bool = false;
	var p2sing:Bool = false;
	var bop:FlxSprite;
	var bop2:FlxSprite;
	var screen:FlxSprite;
	var lightroom:FlxSprite;
	var introsong:FlxSprite = new FlxSprite(0, 0);
	var playersing:String = 'singnow';
	var swagCounter:Int;


	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	// modifiers

	public static var instaFail:Bool = false;

	public static var noFail:Bool = false;
	var camPos:FlxPoint;



	


	override public function create()
	{



		
		Bind.keyCheck();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD2 = new FlxCamera();
		camHUD2.bgColor.alpha = 0;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash0);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camHUD2);


		FlxCamera.defaultCameras = [camGame];

		camGame.setFilters(filters);
		camGame.filtersEnabled = true;
		camHUD.setFilters(camfilters);
		camHUD.filtersEnabled = true;
		camHUD2.setFilters(camfilters);
		camHUD2.filtersEnabled = true;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " , "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  };

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */

		          }
		          default:
		          {
		                  defaultCamZoom = 0.9;
						  var images = [];
					var xml = [];
			
					trace("caching images...");
					if(!FlxG.save.data.loading)
						{
							for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/images/preload")))
								{
									if (!i.endsWith(".png"))
										continue;
									images.push(i);
						
									if (!i.endsWith(".xml"))
										continue;
									xml.push(i);
								}
						
						
								for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/limopreload")))
									{
										if (!i.endsWith(".png"))
											continue;
										images.push(i);
						
										if (!i.endsWith(".xml"))
											continue;
										xml.push(i);
									}
								for (i in images)
									{
										var replaced = i.replace(".png","");
										FlxG.bitmap.add(Paths.image("preload/" + replaced));
										FlxG.bitmap.add(Paths.image("limopreload/" + replaced,"shared"));
										trace("cached " + replaced);
									}
								
								for (i in xml)
									{
										var replaced = i.replace(".xml","");
										FlxG.bitmap.add(Paths.image("preload/" + replaced));
										FlxG.bitmap.add(Paths.image("limopreload/" + replaced,"shared"));
										trace("cached " + replaced);
									}
						}
		                  curStage = 'stage';
		                  bg = new FlxSprite(-600, -330).loadGraphic(Paths.image('mixroom'));
						  bg.setGraphicSize(Std.int(bg.width * 0.88));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  

		                  bgPloosh = new FlxSprite(990, 180).loadGraphic(Paths.image('ploosh'));
						  bgPloosh.setGraphicSize(Std.int(bgPloosh.width * 1));
		                  bgPloosh.antialiasing = true;
		                  bgPloosh.scrollFactor.set(0.9, 0.9);
		                  bgPloosh.active = false;

		                  

						  //add(gf);

		                  stageCurtains = new FlxSprite(-400, -200).loadGraphic(Paths.image('recordroom'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(0.9, 0.9);
		                  stageCurtains.active = false;

		                  

						  stageLights = new FlxSprite(-400, -200).loadGraphic(Paths.image('roomlights'));
		                  stageLights.setGraphicSize(Std.int(stageLights.width * 0.9));
		                  stageLights.updateHitbox();
		                  stageLights.antialiasing = true;
		                  stageLights.scrollFactor.set(0.9, 0.9);
		                  stageLights.active = false;

		                 

						  skyBG = new FlxSprite(-120, -50).loadGraphic(Paths.image('limopreload/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  bgLimo = new FlxSprite(10000, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limopreload/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
								  dancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
								  grpLimoDancers.visible = false;
		                          grpLimoDancers.add(dancer);
		                  }

						  
						  dancer1 = new BackgroundDancer(-10000 , 200);
						  dancer1.scrollFactor.set(0.9, 0.9);
						  dancer1.scale.set(1.5, 1.5);
						  
						  dancer2 = new BackgroundDancer(10000 , 200);
						  dancer2.scrollFactor.set(0.9, 0.9);
						  dancer2.scale.set(1.5, 1.5);

						  dancerlimo1 = new BackgroundDancer(10000 , 70);
						  dancerlimo1.scrollFactor.set(0.4, 0.4);
						  dancerlimo1.scale.set(1.1, 1.1);
						  dancerlimo2 = new BackgroundDancer(390 , -1000);
						  dancerlimo2.scrollFactor.set(0.4, 0.4);
						  dancerlimo2.scale.set(1.1, 1.1);
						  dancerlimo3 = new BackgroundDancer(760 , -1000);
						  dancerlimo3.scrollFactor.set(0.4, 0.4);
						  dancerlimo3.scale.set(1.1, 1.1);
						  dancerlimo4 = new BackgroundDancer(1100 , -1000);
						  dancerlimo4.scrollFactor.set(0.4, 0.4);
						  dancerlimo4.scale.set(1.1, 1.1);
						  dancerlimo5 = new BackgroundDancer(1400 , -1000);
						  dancerlimo5.scrollFactor.set(0.4, 0.4);
						  dancerlimo5.scale.set(1.1, 1.1);

		                  overlayShit = new FlxSprite(-500, -600).loadGraphic(Paths.image('limopreload/limoOverlay'));
		                  overlayShit.alpha = 0.5;

						  trace(dancer.x);


		                  var limoTex = Paths.getSparrowAtlas('limopreload/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

						  overlayShit.visible = false;
						  dancer.visible = false;
						  bgLimo.visible = false;
						  skyBG.visible = false;
						  limo.visible = false;
						  grpLimoDancers.visible = false;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limopreload/fastCarLol'));
		                  
						  stagebg = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/stageback'));
						  stagebg.antialiasing = true;
						  stagebg.scrollFactor.set(0.9, 0.9);
						  stagebg.active = false;
							add(stagebg);

							gfstageFront = new FlxSprite(-650, 570).loadGraphic(Paths.image('stage/stagefront'));
						gfstageFront.setGraphicSize(Std.int(gfstageFront.width * 1.1));
						gfstageFront.updateHitbox();
						gfstageFront.antialiasing = true;
						gfstageFront.scrollFactor.set(0.9, 0.9);
						gfstageFront.active = false;
						add(gfstageFront);

						add(dancer1);
						add(dancer2);
						add(dancerlimo2);
						add(dancerlimo3);
						add(dancerlimo1);
						add(dancerlimo4);
						add(dancerlimo5);
						add(dad);
						

						gfstageCurtains = new FlxSprite(-550, -400).loadGraphic(Paths.image('stage/stagecurtains'));
						gfstageCurtains.setGraphicSize(Std.int(gfstageCurtains.width * 0.9));
						gfstageCurtains.updateHitbox();
						gfstageCurtains.antialiasing = true;
						gfstageCurtains.scrollFactor.set(1.3, 1.3);
						gfstageCurtains.active = false;

						add(gfstageCurtains);
						screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						screen.alpha = 0;
						screen.scale.set(3, 3);
						screen.cameras = [camGame];
						//250 400
						bop = new FlxSprite(10000, 450);
						bop.scale.set(1.2,1.2);
						bop.frames = Paths.getSparrowAtlas('preload/characters');
						bop.animation.addByPrefix('idle', 'back characters', 24, false);
						
						bop2 = new FlxSprite(-10000, 800);
						bop2.scale.set(1.5,1.5);
						bop2.frames = Paths.getSparrowAtlas('preload/characters');
						bop2.animation.addByPrefix('idle', 'front characters', 24, false);
						bop2.visible = false;
						bop.visible = false;
						gfstageCurtains.visible = false;
						gfstageFront.visible = false;
						stagebg.visible = false;

						introsong.frames = Paths.getSparrowAtlas('intro');
						introsong.animation.addByPrefix("idle", "intro", 24);
						introsong.antialiasing = true;
						introsong.screenCenter();
						introsong.scrollFactor.set();

						
						lightroom = new FlxSprite(0, 0).loadGraphic(Paths.image('nothing'));
						lightroom.screenCenter();
						lightroom.updateHitbox();
						lightroom.antialiasing = true;
						lightroom.cameras = [camGame];
						lightroom.scale.set(5,5);
						lightroom.active = false;
		          }
              }


		dad = new Character(100, 100, SONG.player2);
		pico = new Character(-500, 400, 'pico');

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'stage':
				boyfriend.x += 170;
				gf.x += 70;
				gf.y -= 40;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(bg);
		add(bgPloosh);
		add(gf);
		add(stageCurtains);
		add(stageLights);

		// Shitty layering but whatev it works LOL
		
		add(limo);
		
	
		add(dad);
		add(pico);
		pico.x -= 300;
		add(boyfriend);
		add(gfstageCurtains);

		add(bop);
		add(bop2);
		
		//add(introsong);
		if (SONG.song.toLowerCase() == "ok-friday")
			{
				add(lightroom);
			}
			
		

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.02);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);



		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var p1ColorBar:FlxColor = new FlxColor();
		var p2ColorBar:FlxColor = new FlxColor();

		switch (SONG.player1) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p1ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p1ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p1ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p1ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p1ColorBar.setRGB(188, 95, 183, 255);
			}
			case 'dad':
			{
				p1ColorBar.setRGB(255, 80, 84, 255);
			}
			case 'mom' | 'mom-car':
			{
				p1ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p1ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p1ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p1ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p1ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p1ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p1ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p1ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p1ColorBar.setRGB(255, 0, 0, 255);
			}
		}

		switch (SONG.player2) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p2ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p2ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p2ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p2ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p2ColorBar.setRGB(255, 99 ,71 , 255);
			}
			case 'dad':
			{
				p2ColorBar.setRGB(255, 80, 84, 255);
			}
			case 'mom' | 'mom-car':
			{
				p2ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p2ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p2ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p2ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p2ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p2ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p2ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p2ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p2ColorBar.setRGB(255, 0, 0, 255);
			}
		}
		
		healthBar.createFilledBar(p2ColorBar, p1ColorBar);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + 100, healthBarBG.y + 45, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD2];
		healthBarBG.cameras = [camHUD2];
		iconP1.cameras = [camHUD2];
		iconP2.cameras = [camHUD2];
		scoreTxt.cameras = [camHUD2];
		doof.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function intro(){
		
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.quadInOut});
		

	}


	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		swagCounter = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if(!introstart)
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
					introsong.animation.stop();
					introsong.active = false;
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if(!introstart)
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if(!introstart)
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if(!introstart)
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		FlxG.save.data.gf = false;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
	
				dontevensing();
				singnow('bf');
				singnow('dad');
			if(curSong == 'Ok-Friday')
				{
					camHUD2.alpha = 0;
					camHUD.alpha = 0;
				}
		

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		

	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}



		
		
		super.update(elapsed);


		if(FlxG.save.data.shadersOn)
		{
			if (chromOn)
		{
		
			ch = FlxG.random.int(1,5) / 1000;
			ch = FlxG.random.int(1,5) / 1000;
			Shaders.setChrome(ch);
			
		}
		else
		{


			Shaders.setChrome(0);
			
			
		}


		if (radialBlurOn)
		{
			

			Shaders.setRadialBlur(640+(FlxG.random.int(-10,10)),360+(FlxG.random.int(-10,10)),FlxG.random.float(0.001,0.005));
			
		}
		else
		{


			Shaders.setRadialBlur(0, 0, 0);
			
			
		}

		}
		

		

		


		// ranking system
		if(totalAccuracy == 100)
		{
			totalRank = "S+";
		}
		else if(totalAccuracy < 100 && totalAccuracy >= 90)
		{
			totalRank = "S";
		}
		else if(totalAccuracy < 90 && totalAccuracy >= 70)
		{
			totalRank = "A";
		}
		else if(totalAccuracy < 70 && totalAccuracy >= 60)
		{
			totalRank = "B";
		}
		else if(totalAccuracy < 60 && totalAccuracy >= 40)
		{
			totalRank = "C";
		}
		else if(totalAccuracy < 40 && totalAccuracy >= 20)
		{
			totalRank = "D";
		}
		else if(totalAccuracy < 20 && totalAccuracy >= 0)
		{
			totalRank = "F";
		}


		if(instaFail == true && misses >= 1)
		{
			health = 0;
		}

		

		if(misses == 0 && songNotesHit == 0)
			totalAccuracy = 0;
		else
			totalAccuracy = FlxMath.roundDecimal((songNotesHit / (songNotesHit + misses) * 100), 2);
		
		scoreTxt.text = "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank;
		

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					if (picosing == true)
						{

						
						camFollow.setPosition(pico.getMidpoint().x + 250, pico.getMidpoint().y - 100);
						camPos.set(pico.getGraphicMidpoint().x, pico.getGraphicMidpoint().y);
						}
					else if (center == true)
						{
							//camPos.set(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
							camFollow.setPosition(gf.getMidpoint().x , gf.getMidpoint().y);
						}
					else if (center2 == true)
						{
							//camPos.set(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
							camFollow.setPosition(gf.getMidpoint().x - 140 , gf.getMidpoint().y + 150);
						}
					else if (picosing == false && center == false)
						{
							camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
							camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);	
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
	
					switch (dad.curCharacter)
					{
						case 'mom':
							camFollow.y = dad.getMidpoint().y;
						case 'senpai':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'senpai-angry':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
					}
	
					if (dad.curCharacter == 'mom')
						vocals.volume = 1;
	
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						tweenCamIn();
					}
					}
				}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			deathCounter++;
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") ","Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					var dadsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

					if(picosing)
						{
							pico.playAnim('sing' + dadsDir[daNote.noteData], true);
							pico.holdTimer = 0;
						}
					if(p2sing)
						{
							dad.playAnim('sing' + dadsDir[daNote.noteData], true);
							dad.holdTimer = 0;
						}

					strumLineNotes.forEach(function(spr:FlxSprite)
							{
								if(spr.ID == Math.abs(daNote.noteData))
								{
									spr.animation.play('confirm', true);
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										
										spr.animation.play('static', true);
										if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
										
									});
								
									if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
									{
										spr.animation.play('static', true);
									}
								}
								else if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
								{
									spr.animation.play('static', true);
								}
								

								if(dad.animation.curAnim.name == 'idle')
								{
									spr.animation.play('static', true);
								}

								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
								
							});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (FlxG.save.data.downscroll){
					daNote.y = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * SONG.speed);
				}
				else{
					daNote.y = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * SONG.speed);
				}


				if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
				{

					if ((daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote.noteData);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);



			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				




				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				}

				
			}
		
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		var splashIsOn:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			
			totalAccuracy += 0.2;
			score = 50;
			splashIsOn = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';

			totalAccuracy += 0.5;
			score = 100;
			splashIsOn = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			
			totalAccuracy += 0.8;
			score = 200;
			splashIsOn = false;
		}
		else
		{
			daRating = 'sick';

			totalAccuracy += 1;
			score = 350;
			splashIsOn = true;
		}

		if (totalAccuracy > (misses + songNotesHit)) {
			totalAccuracy = (misses + songNotesHit);
		}

		if(splashIsOn == true)
		{
			var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			a.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(a);
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	

	private function keyShit():Void
	{
		var control = PlayerSettings.player1.controls;

		// control arrays, order L D U R
		var holdArray:Array<Bool> = [control.LEFT, control.DOWN, control.UP, control.RIGHT];
		var pressArray:Array<Bool> = [
			control.LEFT_P,
			control.DOWN_P,
			control.UP_P,
			control.RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			control.LEFT_R,
			control.DOWN_R,
			control.UP_R,
			control.RIGHT_R
		];
	 
		// FlxG.watch.addQuick('asdfa', upP);
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{

			songNotesHit += 1;

			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
					{
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote);
					}
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.alpha != 0.1)
						goodNoteHit(daNote);
				});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !pressArray[0] && !pressArray[1] && !pressArray[2] && !pressArray[3])
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdArray[spr.ID])
					spr.animation.play('static');
	 
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
		});
	}


	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned && noFail == false)
		{
			misses++;
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			if (bfsing)
				{
					switch (direction)
					{
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
					}
				}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
		songNotesHit += 1;
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

					if (bfsing)
						{
							boyfriend.playAnim('sing' + sDir[note.noteData], true);
							boyfriend.holdTimer = 0;
						}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		//FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	function dontevensing():Void
		{
			picosing = false;
			bfsing = false;
			p2sing = false;
		}
	function singnow(characters:String):Void
		{
			switch(characters)
			{
				case 'bf':
					bfsing = true;
				case 'pico':
					picosing = true;
				case 'dad':
					p2sing = true;				
			}
		}
	
	
	var stepOfLast = 0;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
		if (curStep != stepOfLast && curSong == 'Ok-Friday')
			{
				switch(curStep)
				{
					case 1:
						center = true;
						dontevensing();
						singnow('dad');
						singnow('bf');
						//FlxTween.tween(screen, {alpha: 1}, 2);
					case 80:
						camHUD.zoom = 0.3;
					case 94:
						intro();
						FlxTween.tween(lightroom, {alpha: 0}, 1);
					case 101:
						defaultCamZoom = 0.9;
					//	camZooming = false;
						center = false;
						FlxTween.tween(camHUD, {alpha: 1}, 1);
						FlxTween.tween(camHUD2, {alpha: 1}, 1);
					case 220:
						center = true;
					case 226:
						camHUD.visible = false;
						camHUD2.visible = false;
						boyfriend.playAnim('hey');
						dad.playAnim('yeah');
						gf.playAnim('cheer');
						defaultCamZoom = 0.8;
						center = true;
					case 228:
						FlxG.camera.follow(camFollow, 0.02);
						defaultCamZoom = 0.9;
						center = false;
						camHUD.visible = true;
						camHUD2.visible = true;
					case 356:
						FlxTween.tween(pico, {x: 300}, {ease: FlxEase.expoInOut});
							dontevensing();
							singnow('pico');
							singnow('bf');
							dad.playAnim('idle');
							FlxTween.tween(camHUD, {alpha: 0}, 1);
							FlxTween.tween(camHUD2, {alpha: 0}, 1);
							iconP2.animation.play("pico");
					case 388:
						defaultCamZoom = 1;
					case 390:
						defaultCamZoom = 1.5;
					case 393:
						defaultCamZoom = 0.9;
						boyfriend.playAnim('hey');
						dad.playAnim('yeah');
						gf.playAnim('cheer');
					case 396:
						dad.playAnim('idle');
					case 480:
						FlxTween.tween(camHUD, {alpha: 1}, 1);
						FlxTween.tween(camHUD2, {alpha: 1}, 1);
					case 490:
						iconP2.animation.play("dad");
						FlxTween.tween(pico, {x: -1000}, {ease: FlxEase.expoInOut});
							dontevensing();
							singnow('dad');
							singnow('bf');
					case 618:
						FlxG.camera.flash(FlxColor.WHITE, 1);
						defaultCamZoom = 1;
						remove(boyfriend);
						boyfriend.destroy();
						boyfriend = new Boyfriend(770,450,"bfcar");
						add(boyfriend);
						overlayShit.visible = true;
						dancer.visible = false;
						bgLimo.visible = true;
						skyBG.visible = true;
						limo.visible = true;

						bg.visible = false;
						bgPloosh.visible = false;
						stageCurtains.visible = false;
						stageLights.visible = false;
						boyfriend.y -= 220;
						boyfriend.x += 260;
						camFollow.x = boyfriend.getMidpoint().x - 300;
						gf.visible = false;
					case 670:
						FlxTween.tween(bgLimo, {x: -200}, {ease: FlxEase.expoInOut});
						FlxTween.tween(dancerlimo1, {x: 90}, {ease: FlxEase.expoInOut});
					case 693:
						FlxTween.tween(dancerlimo2, {y: 70}, {ease: FlxEase.expoInOut});
					case 708:
						FlxTween.tween(dancerlimo3, {y: 70}, {ease: FlxEase.expoInOut});
					case 724:
						FlxTween.tween(dancerlimo4, {y: 70}, {ease: FlxEase.expoInOut});
					case 743:
						FlxTween.tween(dancerlimo5, {y: 70}, {ease: FlxEase.expoInOut});
					case 863:
						//FlxG.camera.flash(FlxColor.BLACK, 1);
					case 870:
						FlxG.camera.flash(FlxColor.BLACK, 5);
						iconP2.animation.play("gf");
						remove (pico);
						pico = new Character(400, 130,"gfspeakers");
						remove(gf);
						gf.destroy();
						gf = new Character(400, 130,"gfr");
						add(gf);
						gf.visible = false;
					
						
						defaultCamZoom = 1;
		
						dontevensing();
						
						singnow('pico');
						singnow('bf');
						FlxTween.tween(camHUD, {alpha: 0}, 1);
						FlxTween.tween(camHUD2, {alpha: 0}, 1);
						overlayShit.visible = false;
						  dancer.visible = false;
						  bgLimo.visible = false;
						  skyBG.visible = false;
						  limo.visible = false;
						  dancerlimo1.visible = false;
						  dancerlimo2.visible = false;
						  dancerlimo3.visible = false;
						  dancerlimo4.visible = false;
						  dancerlimo5.visible = false;
						  grpLimoDancers.visible = false;
						gfstageCurtains.visible = true;
						gfstageFront.visible = true;
						stagebg.visible = true;
						gf.visible = false;
						//dad.x -= 800;
						//remove(pico);
						dad.visible = false;
						remove(boyfriend);
						boyfriend.destroy();
						boyfriend = new Boyfriend(770,450,"bf");
						add(pico);
						add(boyfriend);
					case 1026:
						FlxTween.tween(camHUD, {alpha: 1}, 1);
						FlxTween.tween(camHUD2, {alpha: 1}, 1);
					case 1069:
						iconP2.animation.play("dad");
						gf.visible = true;
						pico.visible = false;
						FlxG.camera.flash(FlxColor.ORANGE, 2);
						
						dad.visible = true;
						FlxTween.tween(pico, {x: -800}, {ease: FlxEase.expoInOut});
						dontevensing();
						singnow('bf');
						singnow('dad');
					case 1071:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1077 | 1232 | 1251:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1088 | 1241 | 1252:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1094 | 1253:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1098 | 1229 | 1254:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1106 | 1235 | 1255:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1111 | 1225 | 1256:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1121 | 1238 | 1257:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1128 | 1258:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1131 | 1218 | 1259:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1136 | 1221 | 1260:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1144 | 1261:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1148 | 1202 | 1261:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1157 | 1262:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1161 | 1216 | 1263:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1776:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1186:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1191 | 1212:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1194:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1194:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1207:
						defaultCamZoom = 1;
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								defaultCamZoom = 0.9;
							});
					case 1264:
						FlxG.camera.flash(FlxColor.BLACK, 3);
					case 1272:
						
						FlxG.camera.flash(FlxColor.WHITE, 1);
						FlxTween.tween(dancer1, {x: -200}, {ease: FlxEase.expoInOut});
						FlxTween.tween(dancer2, {x: 1000}, {ease: FlxEase.expoInOut});
						defaultCamZoom = 0.9;
						center = true;
						dontevensing();
						singnow('bf');
						singnow('dad');
					case 1079 | 1091 | 1103 | 1116 | 1128 | 1140 | 1141 | 1153 | 1166:
						gf.playAnim('cheer');
					case 1378:
						center = true;
					case 1381:
						defaultCamZoom = 1.5;
						center = true;
					case 1397:
						FlxG.camera.flash(FlxColor.WHITE, 1);
						defaultCamZoom = 0.5;

						center = false;
						FlxTween.tween(bop, {x: -600}, {ease: FlxEase.expoInOut});
						FlxTween.tween(bop2, {x: -400}, {ease: FlxEase.expoInOut});
						bop2.visible = true;
						bop.visible = true;
						center2 = true;

					
				}
				stepOfLast = curStep;
			}
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC,true,  songLength - Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if(FlxG.save.data.shadersOn)
		{
			if (curBeat > 0 && !shadersLoaded)
		{
			shadersLoaded = true;

			filters.push(Shaders.chromaticAberration);
			filters.push(Shaders.radialBlur);
			
			camfilters.push(Shaders.chromaticAberration);
			camfilters.push(Shaders.radialBlur);


		}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
			case 'stage':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
				dancer1.dance();
				dancer2.dance();
				dancerlimo1.dance();
				dancerlimo2.dance();
				dancerlimo3.dance();
				dancerlimo4.dance();
				dancerlimo5.dance();
				bop.animation.play('idle', true);
				bop2.animation.play('idle', true);

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;

					phillyCityLights.members[curLight].alpha = 1;
					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.crochet / 1000 * 4, {ease: FlxEase.linear});
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
