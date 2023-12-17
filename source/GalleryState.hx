package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GalleryState extends MusicBeatState //awesome..
{
    public var galleryImages:Array<Array<String>> = 
    [
        [
            'Joeseph Promo',
            'JOESEPH_DEMO_PROMO',
            'The promotion art for the joeseph demo'
        ],
        [
            'Joeseph.',
            'JOESEPHARMY',
            ''
        ], 
        [
            'Serious Joeseph',
            'seriousjoeseph',
            'Joeseph if he was serious'
        ], 
        [
            'Joeseph Art',
            'joeseph2',
            'Made by boo'
        ], 
        [
            'anime girl joeseph sketch',
            'animejoeseph',
            'Made by boo'
        ], 
        [
            'Joeseph W (No Effects)',
            'gonna-joeseph',
            'Joeseph W without effects'
        ],
        [
            "Joeseph's Parents",
            'joes_parents',
            "Joeseph's parents"
        ],
        [
            'Old Joeseph',
            'joesephold',
            ''
        ],
        [
            'Old Joeseph Cover',
            'oldjoesephcover',
            'Old freeplay cover art for joeseph'
        ],
        [
            'Joeseph Art 2',
            'bandojoeseph',
            'Made by Bando'
        ],
        [
            'Joeseph Art 3',
            '707joeseph',
            'Made by 707'
        ],
        [
            'joeseph true form',
            'JOESEPH_TRUE_FORM',
            'not canon'
        ],
        [
            'yeah',
            'yeah',
            ''
        ],
        [
            'yeah 2',
            'yeah2',
            ''
        ],
        [
            'yeah 3',
            'yeah3',
            ''
        ],
        [
            'Joeseph Art 4',
            '707joeseph2',
            'Made by 707'
        ],
        [
            'Ethan Menu Art',
            'menuartethan',
            'Art for an old menu concept that was never used'
        ],
        [
            'Joeseph Menu Art',
            'menuartjoeseph',
            'Art for an old menu concept that was never used'
        ],
        [
            'Wilson Menu Art',
            'menuartwilson',
            'Art for an old menu concept that was never used'
        ],
        [
            'Amby Menu Art',
            'menuartamby',
            'Art for an old menu concept that was never used'
        ],
        [
            'Joeseph Art 5',
            'jose',
            'beautiful (Made by Avery)'
        ],
        [
            'Joeseph Art 6',
            'joeseph_lisa',
            'Made by boo'
        ],
        [
            'Joeraph',
            'joeraph',
            'oh no'
        ],
        [
            'abomination',
            'Mbestjo',
            'oh god'
        ]
    ];

    /*  
        [
            'Name',
            'Image Name',
            'Description'
        ], 
    */

    var totalImages:Int = 0;

    var curSelected:Int = 0;

    var bg:FlxSprite;
    var grid:FlxBackdrop;
    var bar1:FlxBackdrop;
    var bar2:FlxBackdrop;

    var currentImage:FlxSprite;
    var titleText:FlxText;
    var descriptionText:FlxText;
    var imageSelectedText:FlxText;

    var imagePath:String = 'gallery/';

    var infoText:FlxText;
    var scaleInfoText:FlxText;

    var curScale:Float = 0.4;

    var imageLock:Bool = false;

    var awesometext1:String = "Use the Scroll Wheel to change image size | Hold CTRL or SHIFT to change scaling multiplier | Press SPACE to toggle movement";
    var awesometext2:String = "Use the Scroll Wheel to change image size | Hold CTRL or SHIFT to change movement speed | Move the image around with your UI keys";

    override function create()
    {
        bg = new FlxSprite().loadGraphic(Paths.image('menuNegated'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.color = 0xCC5AD0;
        bg.updateHitbox();
        bg.screenCenter();
		add(bg);

        grid = new FlxBackdrop(Paths.image('grid'), 0.2, 0, true, true);
		grid.setGraphicSize(Std.int(grid.width * 3), Std.int(grid.height * 3));
		grid.velocity.set(100, 100);
		grid.updateHitbox();
		grid.alpha = 0.2;
		grid.screenCenter(X);
		add(grid);

        currentImage = new FlxSprite().loadGraphic(Paths.image(imagePath + galleryImages[curSelected][1]));
		currentImage.antialiasing = ClientPrefs.globalAntialiasing;
        currentImage.updateHitbox();
        currentImage.screenCenter();
		add(currentImage);

        bar1 = new FlxBackdrop(Paths.image('sonicbars'), 0.2, 0, true, false);
		bar1.antialiasing = ClientPrefs.globalAntialiasing;
		bar1.velocity.set(50, 0);
		bar1.updateHitbox();
		bar1.screenCenter(X);
		bar1.y = FlxG.height - 110;
		add(bar1);

		bar2 = new FlxBackdrop(Paths.image('sonicbars2'), 0.2, 0, true, false);
		bar2.antialiasing = ClientPrefs.globalAntialiasing;
		bar2.velocity.set(-50, 0);
		bar2.updateHitbox();
		bar2.screenCenter(X);
		bar2.y = -50;
		add(bar2);

        titleText = new FlxText(0, FlxG.height * 0.8, FlxG.width, "", 76);
		titleText.setFormat(Paths.font("vcr.ttf"), 76, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.screenCenter(X);
		add(titleText);

        descriptionText = new FlxText(0, titleText.y + 90, FlxG.width, "", 24);
		descriptionText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.screenCenter(X);
		add(descriptionText);

        totalImages = galleryImages.length;

        imageSelectedText = new FlxText(0, titleText.y - 40, FlxG.width, "", 36);
		imageSelectedText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		imageSelectedText.screenCenter(X);
		add(imageSelectedText);

        infoText = new FlxText(0, 10, FlxG.width, awesometext1, 18);
		infoText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		infoText.screenCenter(X);
		add(infoText);

        scaleInfoText = new FlxText(0, infoText.y + 40, FlxG.width, "", 18);
		scaleInfoText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		scaleInfoText.screenCenter(X);
		add(scaleInfoText);

        updateImage();

        super.create();
    }

    override function update(elapsed:Float)
    {
        var scaling:Float = 0.1;
		if (FlxG.keys.pressed.SHIFT) 
            scaling = 0.2;
        else if (FlxG.keys.pressed.CONTROL) 
            scaling = 0.05;

        var moveSpeed:Float = 5;
		if (FlxG.keys.pressed.SHIFT) 
            moveSpeed = 10;
        else if (FlxG.keys.pressed.CONTROL) 
            moveSpeed = 1;
        
        if (FlxG.mouse.wheel != 0) {
            curScale += scaling * FlxG.mouse.wheel;
            trace(curScale);
        }

        currentImage.setGraphicSize(Std.int(currentImage.width * curScale), Std.int(currentImage.height * curScale));
        if (!imageLock) {
            scaleInfoText.text = 'Scale: ' + curScale + '\nScaling: ' + scaling;
            infoText.text = awesometext1;
        } else {
            scaleInfoText.text = 'Scale: ' + curScale + '\nMovement: ' + moveSpeed;
            infoText.text = awesometext2;
        }

        var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
        var space = FlxG.keys.justPressed.SPACE;

        if (rightP && !imageLock)
        {
            updateImage(1);
            currentImage.screenCenter();
        }
        if (leftP && !imageLock)
        {
            updateImage(-1);
            currentImage.screenCenter();
        }
        if (space)
        {
            if (imageLock == false)
                imageLock = true;
            else if (imageLock == true)
                imageLock = false;
        }

        if (imageLock)
        {
            if (controls.UI_RIGHT)
            {
                currentImage.x += moveSpeed;
            }

            if (controls.UI_LEFT)
            {
                currentImage.x -= moveSpeed;
            }

            if (controls.UI_UP)
            {
                currentImage.y -= moveSpeed;
            }

            if (controls.UI_DOWN)
            {
                currentImage.y += moveSpeed;
            }
        }

        if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

        super.update(elapsed);
    }

    function updateImage(value:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += value;
        //curScale = 1;

        if (curSelected < 0)
			curSelected = galleryImages.length - 1;
		if (curSelected >= galleryImages.length)
			curSelected = 0;

        currentImage.loadGraphic(Paths.image(imagePath + galleryImages[curSelected][1]));
        titleText.text = galleryImages[curSelected][0];
        descriptionText.text = galleryImages[curSelected][2];

        imageSelectedText.text = '< ' + (curSelected + 1) + '/' + totalImages + ' >';
    }
}