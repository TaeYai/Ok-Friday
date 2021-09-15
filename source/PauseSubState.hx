package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var difficultyChoices:Array<String> = ["Easy", "Normal", "Hard", "Back"];
	var modifiersChoices:Array<String> = ["Insta Fail", "No Fail", "Back"];
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Modifiers', 'Exit to menu'];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Modifiers', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeathCounter:FlxText = new FlxText(20,79,0,"",32);
		levelDeathCounter.text += "Blue balled: " + PlayState.deathCounter;
		levelDeathCounter.scrollFactor.set();
		levelDeathCounter.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeathCounter.updateHitbox();
		add(levelDeathCounter);

		var levelModifier1:FlxText = new FlxText(20,79 + 32,0,"",32);
		levelModifier1.text += "Insta. Fail = " + (!PlayState.instaFail ? "false" : "true");
		levelModifier1.scrollFactor.set();
		levelModifier1.setFormat(Paths.font('vcr.ttf'), 32);
		levelModifier1.updateHitbox();
		add(levelModifier1);

		

		var levelModifier4:FlxText = new FlxText(20,79 + 64,0,"",32);
		levelModifier4.text += "No Fail = " + (!PlayState.noFail ? "false" : "true");
		levelModifier4.scrollFactor.set();
		levelModifier4.setFormat(Paths.font('vcr.ttf'), 32);
		levelModifier4.updateHitbox();
		add(levelModifier4);

		

		

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeathCounter.alpha = 0;
		levelModifier1.alpha = 0;
		
		levelModifier4.alpha = 0;
		

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeathCounter.x = FlxG.width - (levelDeathCounter.width + 20);
		levelModifier1.x = FlxG.width - (levelModifier1.width + 20);
		
		levelModifier4.x = FlxG.width - (levelModifier4.width + 20);
	
		

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeathCounter, {alpha: 1, y: levelDeathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(levelModifier1, {alpha: 1, y: levelModifier1.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		
		FlxTween.tween(levelModifier4, {alpha: 1, y: levelModifier4.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		
		

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	function regenMenu() 
	{
        
        grpMenuShit.clear();
        
            
        for (a in 0 ... menuItems.length) {
         	var songText:Alphabet = new Alphabet(0, (70 * a) + 30, menuItems[a], true, false);
			songText.isMenuItem = true;
			songText.targetY = a;
			grpMenuShit.add(songText);
         } 
            
        
        curSelected = 0;
        changeSelection();
    }
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
                case "Easy":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-easy", PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 0;
                    
					FlxG.switchState(new PlayState());
					
				case "Normal":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase(), PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 1;
                    
					FlxG.switchState(new PlayState());
					
				case "Hard":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-hard", PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 2;
                    
					FlxG.switchState(new PlayState());
					
				case "Back":
                	menuItems = menuItemsOG;
                	regenMenu();

                case "Insta Fail": //done
                	
                    PlayState.instaFail = !PlayState.instaFail;
                    PlayState.noFail = false;
                    
					FlxG.switchState(new PlayState());

				case "No Fail": //done
                	
                    PlayState.noFail = !PlayState.noFail;
                    PlayState.instaFail = false;
                    
					FlxG.switchState(new PlayState());
				
				case "Modifiers":
					menuItems = modifiersChoices;
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
