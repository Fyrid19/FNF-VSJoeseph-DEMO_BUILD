package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec == "2.6.1")
import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0")
import VideoHandler as MP4Handler;
#else
import vlc.MP4Handler;
#end
#end

class SplashState extends MusicBeatState // plays joeseph splash screen then goes to menu (unless videos arent allowed)
{
    var splashVideoName:String = 'joe_mod_intro_video';

    var skipText:FlxText;

    override function create()
    {
        #if VIDEOS_ALLOWED
        playSplashVideo(splashVideoName);
        #else
        MusicBeatState.switchState(new TitleState()); // cuz no videos allowed!!
        #end

        /*
        skipText = new FlxText(10, FlxG.height - 42, FlxG.width, "Press ENTER to skip", 32);
		skipText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(skipText);
        */

        super.create();
    }

    function playSplashVideo(videoname) {
        var filepath:String = Paths.video(videoname);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + videoname);
			MusicBeatState.switchState(new TitleState());
			return;
		}

        var video:MP4Handler = new MP4Handler();
		#if (hxCodec >= "3.0.0") //had to mix 0.7 with this because i have updated hxcodec teehee :3
		// Recent versions
		video.play(filepath);
		video.onEndReached.add(function()
		{
			video.dispose();
			MusicBeatState.switchState(new TitleState());
			return;
		}, true);
		#else
		// Older versions
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			MusicBeatState.switchState(new TitleState());
			return;
		}
		#end
    }

    function skipSplashVideo(videoname) {
        var filepath:String = Paths.video(videoname);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + videoname);
			MusicBeatState.switchState(new TitleState());
			return;
		}

        var video:MP4Handler = new MP4Handler();
		video.dispose(); // this should do it
        MusicBeatState.switchState(new TitleState());
        FlxG.sound.play(Paths.sound('cancelMenu'));
        return;
    }
}