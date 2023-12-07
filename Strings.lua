pluginName = plugin:GetName();
pluginVersion = plugin:GetVersion();
pluginDescription = string.format("'%s' v%s, by Cube", pluginName, pluginVersion);

-- Language stuff!
clientLanguage = Turbine.Engine:GetLanguage();

EN = Turbine.Language.English;
DE = Turbine.Language.German;
FR = Turbine.Language.French;

_LANG = {
    ["STATUS"] = {
        ["LOADED"] = {
            [EN] = "Loaded " .. pluginDescription;
            [DE] = "Geladen " .. pluginDescription;
        };
        ["UNLOADED"] = {
            [EN] = string.format("'%s' unloaded", pluginName);
        };
    };
    ["DECOY_COMBAT"] = {
        -- Jagerin applied a benefit with Decoy on Jagerin.
        ["DEPLOY_DECOY"] = {
            [EN] = "benefit with Decoy on ";
        };
        -- Jagerin applied a benefit with Deadly Decoy on Jagerin.
        ["DEPLOY_DEADLY_DECOY"] = {
            [EN] = "benefit with Deadly Decoy on ";
        };
        -- "The Wood-troll Warrior scored a hit with a melee double attack on the Deadly Decoy for 85 Common damage to Morale.";
        -- "The Wood-troll Warrior scored a partially parried hit with a moderate swipe attack on the Deadly Decoy for 60 Common damage to Morale.";
        -- "The Wood-troll Warrior scored a partially evaded hit with a weak swipe attack on the Deadly Decoy for 48 Common damage to Morale.";
        -- "The Wood-troll Lobber tried to use a weak swipe attack on the Deadly Decoy but it evaded the attempt.";
        -- "The Wood-troll Warrior scored a partially evaded hit with a melee double attack on the Master Trapper's Deadly Decoy for 1,942 Common damage to Morale."
        -- "The Blackwold scored a hit with a weak melee attack on the Decoy for 9 Common damage to Morale."
        ["DAMAGED"] = {
            [EN] = "scored a .* on the .*Decoy for ([0-9,]+) ";
        };
        -- "The Restless Broadtooth defeated the Decoy."
        -- "The Wood-troll Warrior defeated the Deadly Decoy.";
        -- "The Wood-troll Warrior defeated the Master Trapper's Deadly Decoy.";
        ["DEFEATED"] = {
            [EN] = "defeated the .*Decoy.";
        };
        -- decoyDamage could look like 1,942, remove the comma separator:
        ["DAMAGE_THOUSANDS_SEPARATOR"] = {
            [EN] = "%,";
        };
    };
    ["OUTPUT_MESSAGES"] = {
        ["DECOY_DEPLOYED"] = {
            [EN] = "You deployed a decoy you awesome hunter you!";
        };
        ["DEADLY_DECOY_DEPLOYED"] = {
            [EN] = "You deployed a deadly decoy you awesome hunter you!";
        };
        ["DECOY_DEFEATED"] = {
            [EN] = "Oh no! Your decoy is defeated!";
        };
    };
    ["OPTIONS"] = {
        ["LOCK_WINDOW"] = {
            [EN] = "Lock the window in place";
        };
        ["SCALING"] = {
            [EN] = "Scaling: %.1fx";
            [DE] = "Maßstab: %.1fx";
            [FR] = "Echelle: %.1fx";
        };
    };

};

function GetString(text)
    -- use clientLanguage, it's always right

    -- If they passed in a non-existant thing, return an empty string
    if (text == nil) then return ""; end

    -- If the text is present in the language, return it
    if (text[clientLanguage] ~= nil) then return text[clientLanguage]; end

    -- Otherwise, fall back to English
    return text[EN];
end
