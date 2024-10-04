package options;

import utils.SettingsManager;
import utils.Paths;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.sound.filters.*;
import flixel.sound.filters.effects.*;

class OptionsState extends FlxState {
    private var options:Array<FlxText>;
    private var selectedOption:Int = 0;
    var pingas:FlxFilteredSound;

    override public function create():Void {
        super.create();

        var title = new FlxText(0, 10, FlxG.width, "Options Menu");
        title.setFormat(null, 24, FlxColor.WHITE, "center");
        add(title);

        options = [
            new FlxText(50, 70, 0, "Volume: " + SettingsManager.volumeLevel),
            new FlxText(50, 120, 0, "Sound Test"),
            new FlxText(50, 170, 0, "Resolution: " + SettingsManager.resolutions[SettingsManager.currentResolutionIndex].width + "x" + SettingsManager.resolutions[SettingsManager.currentResolutionIndex].height),
            new FlxText(50, 220, 0, "Toggle Fullscreen"),
            new FlxText(50, 270, 0, "Back")
        ];

        for (option in options) {
            option.setFormat(null, 16, FlxColor.WHITE);
            add(option);
        }
        highlightOption(selectedOption);

        pingas = new FlxFilteredSound();
        pingas.loadEmbedded(Paths.sound('pingas'));
        FlxG.sound.list.add(pingas);
        FlxG.sound.defaultSoundGroup.add(pingas);

        pingas.filter = new FlxSoundFilter();
        pingas.filter.filterType = FlxSoundFilterType.BANDPASS;
        pingas.filter.gainHF = 0.2;
        pingas.filter.gainLF = 0.5;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP) {
            selectedOption = (selectedOption - 1 + options.length) % options.length;
            highlightOption(selectedOption);
        }
        if (FlxG.keys.justPressed.DOWN) {
            selectedOption = (selectedOption + 1) % options.length;
            highlightOption(selectedOption);
        }
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            handleOptionSelection(selectedOption);
        }
        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
            if (selectedOption == 0) {
                adjustVolume(FlxG.keys.justPressed.RIGHT);
            } else if (selectedOption == 2) {
                adjustResolution(FlxG.keys.justPressed.RIGHT);
            }
        }
    }

    private function highlightOption(index:Int):Void {
        for (i in 0...options.length) {
            options[i].color = (i == index) ? FlxColor.YELLOW : FlxColor.WHITE;
        }
    }

    private function handleOptionSelection(index:Int):Void {
        switch (index) {
            case 0:
                // Volume is adjusted using LEFT and RIGHT keys
                return;
            case 1:
                pingas.play();
                return;
            case 2:
                // Resolution is adjusted using LEFT and RIGHT keys
                return;
            case 3:
                FlxG.fullscreen = !FlxG.fullscreen;
                return;
            case 4:
                FlxG.switchState(new states.MainMenuState());
                return;
        }
    }

    private function adjustVolume(increase:Bool):Void {
        if (increase && SettingsManager.volumeLevel < 10) {
            SettingsManager.volumeLevel++;
        } else if (!increase && SettingsManager.volumeLevel > 0) {
            SettingsManager.volumeLevel--;
        }
        FlxG.sound.volume = SettingsManager.volumeLevel / 10;
        options[0].text = "Volume: " + SettingsManager.volumeLevel;
        SettingsManager.saveSettings();
    }

    private function adjustResolution(increase:Bool):Void {
        if (increase && SettingsManager.currentResolutionIndex < SettingsManager.resolutions.length - 1) {
            SettingsManager.currentResolutionIndex++;
        } else if (!increase && SettingsManager.currentResolutionIndex > 0) {
            SettingsManager.currentResolutionIndex--;
        }
        SettingsManager.setResolution(SettingsManager.currentResolutionIndex);
        options[2].text = "Resolution: " + SettingsManager.resolutions[SettingsManager.currentResolutionIndex].width + "x" + SettingsManager.resolutions[SettingsManager.currentResolutionIndex].height;
        SettingsManager.saveSettings();
    }
}