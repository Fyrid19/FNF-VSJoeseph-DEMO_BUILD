package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
    var grid:FlxBackdrop;
    var bar1:FlxBackdrop;
    var bar2:FlxBackdrop;
	var songCover:FlxSprite;
	var songCoverMask:FlxSprite;
	var songCoverFinal:FlxSprite;
	var arrow1:FlxSprite;
	var arrow2:FlxSprite;
	var songText:FlxText;
	var taglineText:FlxText;
	var scoreText:FlxText;
	var errorText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var tagline:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuNegated'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grid = new FlxBackdrop(Paths.image('grid'), 0.2, 0, true, true);
		grid.setGraphicSize(Std.int(grid.width * 4), Std.int(grid.height * 4));
		grid.velocity.set(100, 100);
		grid.updateHitbox();
		grid.alpha = 0.4;
		grid.screenCenter(X);
		add(grid);

		bar1 = new FlxBackdrop(Paths.image('sonicbars'), 0.2, 0, true, false);
		bar1.antialiasing = ClientPrefs.globalAntialiasing;
		bar1.velocity.set(100, 0);
		bar1.updateHitbox();
		bar1.screenCenter(X);
		bar1.y = FlxG.height - 160;
		add(bar1);

		bar2 = new FlxBackdrop(Paths.image('sonicbars2'), 0.2, 0, true, false);
		bar2.antialiasing = ClientPrefs.globalAntialiasing;
		bar2.velocity.set(-100, 0);
		bar2.updateHitbox();
		bar2.screenCenter(X);
		bar2.y = 0;
		add(bar2);

		songCover = new FlxSprite().loadGraphic(Paths.image('covers/cover')); // placeholder image
		songCover.antialiasing = ClientPrefs.globalAntialiasing;
		songCover.updateHitbox();
		songCover.screenCenter();
		//add(songCover);

		songCoverMask = new FlxSprite().loadGraphic(Paths.image('covers/cover_mask'));
		songCoverMask.antialiasing = ClientPrefs.globalAntialiasing;
		songCoverMask.updateHitbox();
		songCoverMask.screenCenter();
		//add(songCoverMask);

		songCoverFinal = new FlxSprite();
		songCoverFinal.antialiasing = ClientPrefs.globalAntialiasing;
		songCoverFinal.updateHitbox();
		songCoverFinal.screenCenter();
		songCoverFinal.x -= 180;
		songCoverFinal.y -= 180;
		FlxSpriteUtil.alphaMaskFlxSprite(songCover, songCoverMask, songCoverFinal);
		add(songCoverFinal);

		tagline = getFreeplayTag();

		songText = new FlxText(0, songCover.y + 360, FlxG.width, "", 76);
		songText.setFormat(Paths.font("vcr.ttf"), 76, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songText.text = songs[curSelected].songName;
		add(songText);

		taglineText = new FlxText(0, songText.y + 68, FlxG.width, "", 24);
		taglineText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		taglineText.text = '"' + tagline + '"';
		add(taglineText);

		arrow1 = new FlxSprite().loadGraphic(Paths.image('menu_arrow'));
		arrow1.setGraphicSize(Std.int(arrow1.width * 3), Std.int(arrow1.height * 3));
		arrow1.antialiasing = false;
		arrow1.updateHitbox();
		arrow1.screenCenter(Y);
		arrow1.x = 20;
		add(arrow1);

		arrow2 = new FlxSprite().loadGraphic(Paths.image('menu_arrow'));
		arrow2.setGraphicSize(Std.int(arrow2.width * 3), Std.int(arrow2.height * 3));
		arrow2.antialiasing = false;
		arrow2.updateHitbox();
		arrow2.screenCenter(Y);
		arrow2.x = FlxG.width - 170;
		arrow2.flipX = true;
		add(arrow2);

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, 5, FlxG.width, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		scoreText.screenCenter(X);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0;
		add(scoreBG);

		errorText = new FlxText(0, 0, 600, '"' + songs[curSelected].songName + '"' + ' has no chart!', 28);
		errorText.setFormat(scoreText.font, 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		errorText.alpha = 0;
		errorText.screenCenter();
		add(errorText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		updateSongCoverAndText();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		#if PRELOAD_ALL
		var leText:String = "LEFT and RIGHT arrows to navigate | CTRL to open Gameplay Changers Menu | Alternatively, use the Scroll Wheel + SHIFT to navigate";
		var size:Int = 16;
		#else
		var leText:String = "LEFT and RIGHT arrows to navigate | CTRL to open Gameplay Changers Menu | Alternatively, use the Scroll Wheel + SHIFT to navigate";
		var size:Int = 16;
		#end
		var text:FlxText = new FlxText(0, FlxG.height - 24, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (leftP)
			{
				changeSelection(-shiftMult);
				updateSongCoverAndText();
				holdTime = 0;

				FlxTween.cancelTweensOf(arrow1);
				arrow1.x = 0;
				FlxTween.tween(arrow1, {x: 20}, 1, {ease: FlxEase.circOut});
			}
			if (rightP)
			{
				changeSelection(shiftMult);
				updateSongCoverAndText();
				holdTime = 0;

				FlxTween.cancelTweensOf(arrow2);
				arrow2.x = FlxG.width - 150;
				FlxTween.tween(arrow2, {x: FlxG.width - 170}, 1, {ease: FlxEase.circOut});
			}

			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					updateSongCoverAndText();

					if(controls.UI_LEFT) 
					{
						FlxTween.cancelTweensOf(arrow1);
						arrow1.x = 0;
						FlxTween.tween(arrow1, {x: 20}, 1, {ease: FlxEase.circOut});
					}
					else if(controls.UI_RIGHT) 
					{
						FlxTween.cancelTweensOf(arrow2);
						arrow2.x = FlxG.width - 150;
						FlxTween.tween(arrow2, {x: FlxG.width - 170}, 1, {ease: FlxEase.circOut});
					}
				}
			}

			if(FlxG.mouse.wheel != 0 && FlxG.keys.pressed.SHIFT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-1 * FlxG.mouse.wheel, false);
				updateSongCoverAndText();
			}
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			if (sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) || sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			
			trace(sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)));

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();

			} else {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.cancelTweensOf(errorText);
				errorText.text = '"' + songs[curSelected].songName + '"' + ' has no chart!';
				errorText.alpha = 1;
				FlxTween.tween(errorText, {alpha: 0}, 1, {ease: FlxEase.linear});
				trace('Couldnt find chart');
			}
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function getFreeplayTag():String //stolen from title text..
	{
		var taglist:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplayText'));
		var actualtag:String = '';

		actualtag = taglist[curSelected];

		return actualtag;
	}

	function updateSongCoverAndText() {
		tagline = getFreeplayTag();

		songText.text = songs[curSelected].songName;
		taglineText.text = '"' + tagline + '"';

		//trace('covers/' + songs[curSelected].songName.toLowerCase() + '_cover');

		if (Paths.image('covers/' + songs[curSelected].songName.toLowerCase() + '_cover') != null) {
			songCover.loadGraphic(Paths.image('covers/' + songs[curSelected].songName.toLowerCase() + '_cover'));
			trace(':thumbsupemoji:');
		} else {
			songCover.loadGraphic(Paths.image('covers/cover'));
			trace('ruh roh raggy');
		}
		
		FlxSpriteUtil.alphaMaskFlxSprite(songCover, songCoverMask, songCoverFinal);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}