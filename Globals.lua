
DEFAULT_SETTINGS = {
    ["WINDOW"] = {
        ["LEFT"] = 600 / 1900;
        ["TOP"] = 400 / 1000;
        ["WIDTH"] = 0.0526;
        -- Not saving lock state at this time.
    };
};

imageWidth = 32;  -- Fixed, Decoy & Deadly decoy will be 32x32 until "the future"
imageHeight = 32;

minimumImageWidth = imageWidth / 2;     -- min scaling =  0.5
maximumImageWidth = imageWidth * 10;    -- max scaling = 10.0

SETTINGS = {};

settingsDataScope = Turbine.DataScope.Character;
settingsFilename = "HunterDeadlyDecoy_Settings";

-- this will be true if the number is formatted with a 
-- comma for the decimal place / radix point, false otherwise
isEuroFormat=(tonumber("1,000")==1);

-- create a function to automatcially convert in string format to number:
if (isEuroFormat) then
    function euroNormalize(value)
        if (value == nil) then return 0.0; end
        return tonumber((string.gsub(value, "%.", ",")));
    end
else
    function euroNormalize(value)
        if (value == nil) then return 0.0; end
        return tonumber((string.gsub(value, ",", ".")));
    end
end

function LoadSettings()
    local loadedSettings = PatchDataLoad(
        settingsDataScope,
        settingsFilename);

    -- did we load something good?
    if (type(loadedSettings) == 'table') then
        -- Yes, use what we loaded
        SETTINGS = loadedSettings;

        SETTINGS.WINDOW.LEFT = euroNormalize(SETTINGS.WINDOW.LEFT);
        SETTINGS.WINDOW.TOP = euroNormalize(SETTINGS.WINDOW.TOP);
        SETTINGS.WINDOW.WIDTH = euroNormalize(SETTINGS.WINDOW.WIDTH);

        local displayWidth = Turbine.UI.Display:GetWidth();
        if ((SETTINGS.WINDOW.WIDTH * displayWidth) > maximumImageWidth) then
            SETTINGS.WINDOW.WIDTH = maximumImageWidth / displayWidth;
        end
        if ((SETTINGS.WINDOW.WIDTH * displayWidth) < minimumImageWidth) then
            SETTINGS.WINDOW.WIDTH = minimumImageWidth / displayWidth;
        end
    else
        Turbine.Shell.WriteLine("No save file found!");
        SETTINGS = DEFAULT_SETTINGS;
    end

end

function SaveSettings()
    PatchDataSave(
        settingsDataScope,
        settingsFilename,
        SETTINGS);
end

_DEADLY_DECOY_MAX_HEALTH_PER_CHAR_LEVEL = {
     [6]  = 187.5;
     [7]  = 202.5;
     [8]  = 225;
     [9]  = 247.5;
     [10] = 292.5;
     [11] = 315;
     [12] = 337.5;
     [13] = 360;
     [14] = 382.5;
     [15] = 435;
     [16] = 465;
     [17] = 487.5;
     [18] = 510;
     [19] = 532.5;
     [20] = 600;
     [21] = 630;
     [22] = 652.5;
     [23] = 682.5;
     [24] = 705;
     [25] = 787.5;
     [26] = 810;
     [27] = 840;
     [28] = 870;
     [29] = 900;
     [30] = 922.5;
     [31] = 982.5;
     [32] = 1012.5;
     [33] = 1042.5;
     [34] = 1102.5;
     [35] = 1132.5;
     [36] = 1162.5;
     [37] = 1230;
     [38] = 1267.5;
     [39] = 1297.5;
     [40] = 1402.5;
     [41] = 1477.5;
     [42] = 1597.5;
     [43] = 1717.5;
     [44] = 1845;
     [45] = 1972.5;
     [46] = 2107.5;
     [47] = 2242.5;
     [48] = 2385;
     [49] = 2527.5;
     [50] = 2670;
     [51] = 3240;
     [52] = 3495;
     [53] = 3772.5;
     [54] = 4050;
     [55] = 4342.5;
     [56] = 4642.5;
     [57] = 4957.5;
     [58] = 5280;
     [59] = 5610;
     [60] = 5955;
     [61] = 6300;
     [62] = 6667.5;
     [63] = 6862.5;
     [64] = 7057.5;
     [65] = 7252.5;
     [66] = 7410;
     [67] = 7552.5;
     [68] = 7672.5;
     [69] = 7785;
     [70] = 7867.5;
     [71] = 7935;
     [72] = 7987.5;
     [73] = 8025;
     [74] = 8167.5;
     [75] = 9127.5;
     [76] = 9570;
     [77] = 9660;
     [78] = 10050;
     [79] = 10312.5;
     [80] = 10710;
     [81] = 10950;
     [82] = 11400;
     [83] = 11625;
     [84] = 11925;
     [85] = 12150;
     [86] = 14775;
     [87] = 15075;
     [88] = 15375;
     [89] = 15750;
     [90] = 16050;
     [91] = 16425;
     [92] = 16725;
     [93] = 17100;
     [94] = 17400;
     [95] = 17700;
     [96] = 18075;
     [97] = 18375;
     [98] = 18750;
     [99] = 19050;
     [100] = 19350;
     [101] = 19725;
     [102] = 20025;
     [103] = 20325;
     [104] = 20625;
     [105] = 21300;
     [106] = 28200;
     [107] = 28950;
     [108] = 29700;
     [109] = 30750;
     [110] = 31575;
     [111] = 32250;
     [112] = 33375;
     [113] = 34125;
     [114] = 34800;
     [115] = 37725;
     [116] = 49125;
     [117] = 54225;
     [118] = 59550;
     [119] = 64200;
     [120] = 68925;
     [121] = 87750;
     [122] = 90150;
     [123] = 92700;
     [124] = 93975;
     [125] = 96600;
     [126] = 97800;
     [127] = 100500;
     [128] = 101775;
     [129] = 105825;
     [130] = 109950;
};
