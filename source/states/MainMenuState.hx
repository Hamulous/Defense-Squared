package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import openfl.system.System;
import utils.*;

class MainMenuState extends FlxState
{   
    var menuItems:FlxTypedGroup<FlxSprite>;
    var menuItem:FlxText;
    var optionShit:Array<String> = [
		'Play',
        'Settings',
		'Credits',
		'Quit'
	];

    public static var curSelected:Int = 0;
    var cancheck:Bool = true;

    var editable:Bool = false; // DEBUG THING
    var editbleSprite:FlxSprite;
    var lpo:Int = 700;
    
    override public function create():Void
    {
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;
        
        menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

        var scale:Float = 1;
        
        for (i in 0...optionShit.length)
        {
            var offset:Float = 357 - (Math.max(optionShit.length, 4) - 4) * 80;
            menuItem = new FlxText(274, (i * 40) + offset, optionShit[i], 12);
            menuItem.scale.x = scale;
            menuItem.scale.y = scale;
            menuItem.ID = i;
            menuItem.setFormat(Paths.font("vcr.ttf"), 32);
            menuItems.add(menuItem);
            var scr:Float = (optionShit.length - 4) * 0.135;
            if(optionShit.length < 6) scr = 0;
            menuItem.scrollFactor.set(0, scr);
            //menuItem.antialiasing = ClientPrefs.globalAntialiasing; Save this for settings menu
            //menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
            menuItem.updateHitbox();

            
		    editbleSprite = menuItem;
		    editable = true;
        }
            
        super.create();
    }

    var selectedSomethin:Bool = false;

    override public function update(elapsed:Float):Void
    {
        
		if (FlxG.mouse.visible != true)
        {
            FlxG.mouse.visible = true;
        }

        if (cancheck != false)
        {
            for (i in menuItems)
            {
                if (FlxG.mouse.overlaps(i))
                    {
                        changeItemMOUSE(i.ID);
                        i.alpha = 0.7;
                    }
                else
                    {
                        i.alpha = 1;
                }
            }
        }
        
        if (FlxG.keys.pressed.SHIFT && editable)
            {
                editbleSprite.x = FlxG.mouse.screenX;
                editbleSprite.y = FlxG.mouse.screenY;
            }
        else if (FlxG.keys.justPressed.C && editable)
            {
                trace(editbleSprite);
                trace(lpo);
            }
        else if (FlxG.keys.justPressed.E && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        lpo += 100;
                    else
                        lpo += 15;
                    editbleSprite.setGraphicSize(Std.int(lpo));
                    editbleSprite.updateHitbox();
                }
        else if (FlxG.keys.justPressed.Q && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        lpo -= 100;
                    else
                        lpo -= 15;
                    editbleSprite.setGraphicSize(Std.int(lpo));
                    editbleSprite.updateHitbox();
                }
        else if (FlxG.keys.justPressed.L && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        editbleSprite.x += 50;
                    else
                        editbleSprite.x += 1;
                }
        else if (FlxG.keys.justPressed.K && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        editbleSprite.y += 50;
                    else
                        editbleSprite.y += 1;
                }
        else if (FlxG.keys.justPressed.J && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        editbleSprite.x -= 50;
                    else
                        editbleSprite.x -= 1;
                }
        else if (FlxG.keys.justPressed.I && editable)
                {
                    if (FlxG.keys.pressed.ALT)
                        editbleSprite.y -= 50;
                    else
                        editbleSprite.y -= 1;
                }

        if (!selectedSomethin)
        {
            if (FlxG.mouse.pressed && FlxG.mouse.overlaps(menuItems))
            {
                selectedSomethin = true;
                cancheck = false;

                menuItems.forEach(function(spr:FlxSprite)
                {
                    var daChoice:String = optionShit[curSelected];
                    switch (daChoice)
                    {
                        case 'Play':
                            FlxG.switchState(new states.PlayState());
                        case 'Settings':
                            FlxG.switchState(new options.OptionsState());
                        case 'Quit':
                            System.exit(0);
                    }
                });
                
            }
        }

		super.update(elapsed);
        
        menuItems.forEach(function(spr:FlxSprite)
        {
            spr.screenCenter(X);
        });
    }

    function changeItemMOUSE(huh:Int = 0)
    {
        curSelected = huh;

        if (curSelected >= menuItems.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuItems.length - 1;

        menuItems.forEach(function(spr:FlxSprite)
        {
            spr.alpha = 1; //Place Holder
            spr.updateHitbox();

            if (spr.ID == curSelected)
            {
                spr.alpha = 0.7;
                var add:Float = 0;
                if(menuItems.length > 4) {
                    add = menuItems.length * 8;
                }
                spr.centerOffsets();
            }
        });
    }
}