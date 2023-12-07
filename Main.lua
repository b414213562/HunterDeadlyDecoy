import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";

import "CubePlugins.HunterDeadlyDecoy.Globals"
import "CubePlugins.HunterDeadlyDecoy.Strings"
import "CubePlugins.HunterDeadlyDecoy.Utils"

import "CubePlugins.HunterDeadlyDecoy.HunterDeadlyDecoyWindow"
import "CubePlugins.HunterDeadlyDecoy.VindarPatch"


-- Used to get the current level when summoning a deadly decoy:
localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance();

if (SHOW_DEBUG_OPTIONS) then 
    localPlayer.TargetChanged = function(sender, args)

        Turbine.Shell.WriteLine("Target Changed!");

        local target = localPlayer:GetTarget();
        if (target ~= nil) then
    --        Turbine.Shell.WriteLine("Player's Base Max Morale: " .. dump(localPlayer:GetBaseMaxMorale()));
    --        Turbine.Shell.WriteLine("Player's Max Morale: " .. dump(localPlayer:GetMaxMorale()));
            if (target.GetBaseMaxMorale ~= nil) then
                Turbine.Shell.WriteLine("Target BMM: " .. dump(target:GetBaseMaxMorale()));
                Turbine.Shell.WriteLine("Target MM: " .. dump(target:GetMaxMorale()));
            else
                Turbine.Shell.WriteLine("Target is not an Actor: " .. target:GetName());
            end
        end

        local baseMaxMorale = localPlayer:GetBaseMaxMorale();
        local maxMorale = localPlayer:GetMaxMorale();

        Turbine.Shell.WriteLine("My Base Max Morale: " .. baseMaxMorale);
        Turbine.Shell.WriteLine("My Max Morale: " .. maxMorale);
    end
end

function DecoyDeployed()
    Turbine.Shell.WriteLine(GetString(_LANG.OUTPUT_MESSAGES.DECOY_DEPLOYED));
    hunterDeadlyDecoyWindow:Show(false);
end

function DeadlyDecoyDeployed()
    Turbine.Shell.WriteLine(GetString(_LANG.OUTPUT_MESSAGES.DEADLY_DECOY_DEPLOYED));
    hunterDeadlyDecoyWindow:Show(true);
end

function DecoyDefeated()
    Turbine.Shell.WriteLine(GetString(_LANG.OUTPUT_MESSAGES.DECOY_DEFEATED));
    hunterDeadlyDecoyWindow:Hide();
end

Turbine.Chat.Received = function(sender, args)
    if (args.ChatType == Turbine.ChatType.Death) then
        local textWithoutMarkup = GetRawText(args.Message);
        foundIndexOrNil = string.find(textWithoutMarkup, GetString(_LANG.DECOY_COMBAT.DEFEATED));
        if (foundIndexOrNil ~= nil) then
            DecoyDefeated();
        end
    end

    if (args.ChatType == Turbine.ChatType.PlayerCombat) then
        local textWithoutMarkup = GetRawText(args.Message);
        local foundIndexOrNil = string.find(textWithoutMarkup, GetString(_LANG.DECOY_COMBAT.DEPLOY_DEADLY_DECOY));
        if (foundIndexOrNil ~= nil) then -- we found the text!
            DeadlyDecoyDeployed();
        else
            foundIndexOrNil = string.find(textWithoutMarkup, GetString(_LANG.DECOY_COMBAT.DEPLOY_DECOY));
            if (foundIndexOrNil ~= nil) then
                DecoyDeployed();
            end
        end
    end

    if (args.ChatType == Turbine.ChatType.EnemyCombat) then
        local textWithoutMarkup = GetRawText(args.Message);
        local decoyDamage = string.match(textWithoutMarkup, GetString(_LANG.DECOY_COMBAT.DAMAGED));
        if (decoyDamage ~= nil) then
            decoyDamage = decoyDamage:gsub(GetString(_LANG.DECOY_COMBAT.DAMAGE_THOUSANDS_SEPARATOR), "");
            hunterDeadlyDecoyWindow:DecoyDamage(decoyDamage);
        end
    end

end

function RegisterForUnload()
    Turbine.Plugin.Unload = function(sender, args)
        SaveSettings();

        Turbine.Shell.WriteLine(GetString(_LANG.STATUS.UNLOADED));
    end
end

function UpdateScaleLabelAndBarFromScreenSize()
    local scalingScrollbarValue = SETTINGS.WINDOW.WIDTH * Turbine.UI.Display:GetWidth() * 10 / 32;
    scalingScrollbarLabel:SetText(string.format(GetString(_LANG.OPTIONS.SCALING), scalingScrollbarValue / 10));
    scalingScrollbar:SetValue(scalingScrollbarValue);
end

function DrawOptionsControl()
    options = Turbine.UI.Control();
    plugin.GetOptionsPanel = function(self) return options; end

    options:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1));
    options:SetSize(250, 300);

    -- Lock / Unlock the window for dragging
    local lockedCheckbox = Turbine.UI.Lotro.CheckBox();
    lockedCheckbox:SetParent(options);
    lockedCheckbox:SetPosition(10, 10);
    lockedCheckbox:SetSize(250, 25);
    lockedCheckbox:SetText(GetString(_LANG.OPTIONS.LOCK_WINDOW));
    lockedCheckbox:SetChecked(true);
    lockedCheckbox.CheckedChanged = function(sender, args)
        if (lockedCheckbox:IsChecked()) then
            hunterDeadlyDecoyWindow:LockForMoving();
        else
            hunterDeadlyDecoyWindow:UnlockForMoving();
        end
    end

    local scalingScrollbarValue = SETTINGS.WINDOW.WIDTH * Turbine.UI.Display:GetWidth() * 10 / 32;

    -- Label for the scaling scrollbar
    scalingScrollbarLabel = Turbine.UI.Label();
    scalingScrollbarLabel:SetParent(options);
    scalingScrollbarLabel:SetSize(200, 25);
    scalingScrollbarLabel:SetText(string.format(GetString(_LANG.OPTIONS.SCALING), scalingScrollbarValue / 10));
    scalingScrollbarLabel:SetPosition(10, 60);

    -- Scrollbar to adjust image scaling
    scalingScrollbar = Turbine.UI.Lotro.ScrollBar();
    scalingScrollbar:SetParent(options);
    scalingScrollbar:SetOrientation(Turbine.UI.Orientation.Horizontal);
    scalingScrollbar:SetSize(200, 10);
    scalingScrollbar:SetPosition(10, 90);
    scalingScrollbar:SetMinimum(5);
    scalingScrollbar:SetMaximum(100);
    -- Convert SETTINGS.WINDOW.WIDTH to a multiplier
    -- .016 => 1x for 1920
    scalingScrollbar:SetValue(scalingScrollbarValue);
    scalingScrollbar.ValueChanged = function(sender, args)
        local currentValue = scalingScrollbar:GetValue();
        local scaledValue = currentValue / 10;

        -- practical minimum: 1x = 32x32, in 1920 x 1080 => 32/1920 = about 1.6%
        -- practical maximum: 10x = 320x320, about 16%

        scalingScrollbarLabel:SetText(string.format(GetString(_LANG.OPTIONS.SCALING), scaledValue));

        local screenWidth = Turbine.UI.Display:GetWidth();
        SETTINGS.WINDOW.WIDTH = (32 * scaledValue) / screenWidth;
        hunterDeadlyDecoyWindow:Redraw();
    end


    if (SHOW_DEBUG_OPTIONS == true) then
        -- Pretend a decoy was launched
        local debugDecoyButton = Turbine.UI.Lotro.Button();
        debugDecoyButton:SetParent(options);
        debugDecoyButton:SetText("Deploy Dummy Decoy!");
        debugDecoyButton:SetPosition(10, 200);
        debugDecoyButton:SetWidth(150);
        debugDecoyButton.Click = function(sender, args)
            DecoyDeployed();
        end

        -- Pretend a deadly decoy was launched
        local debugDeadlyDecoyButton = Turbine.UI.Lotro.Button();
        debugDeadlyDecoyButton:SetParent(options);
        debugDeadlyDecoyButton:SetText("Deploy Dummy Deadly Decoy!");
        debugDeadlyDecoyButton:SetPosition(10, 230);
        debugDeadlyDecoyButton:SetWidth(200);
        debugDeadlyDecoyButton.Click = function(sender, args)
            DeadlyDecoyDeployed();
        end

        -- Take some damage!
        ---- Text Box
        local debugDamageAmount = Turbine.UI.Lotro.TextBox();
        debugDamageAmount:SetParent(options);
        debugDamageAmount:SetPosition(10, 260);
        debugDamageAmount:SetSize(100, 25);
        debugDamageAmount:SetMultiline(false);


        ---- Button
        local debugTakeDamage = Turbine.UI.Lotro.Button();
        debugTakeDamage:SetParent(options);
        debugTakeDamage:SetText("Damage!");
        debugTakeDamage:SetPosition(125, 260);
        debugTakeDamage:SetWidth(100);
        debugTakeDamage.Click = function(sender, args)
            hunterDeadlyDecoyWindow:DecoyDamage(debugDamageAmount:GetText());
        end        
    end

end

function DrawMainWindow()
    hunterDeadlyDecoyWindow = HunterDeadlyDecoyWindow();
end

function CreateDisplaySizeChangedNonsense()
    displaySizeListener = Turbine.UI.Window();
    displaySizeListener:SetVisible(true);
    displaySizeListener:SetStretchMode(0);
    displaySizeListener:SetSize(1, 1);
    displaySizeListener:SetStretchMode(1);
    displaySizeListener:SetWantsUpdates(true);

    function displaySizeListener:Update()
        displaySizeListener:SetSize(2, 2);
        self.ignoreSizeChangedEvents = 0;
        self:SetWantsUpdates(false);
        self.Update = self._Update;
        self.SizeChanged = self._SizeChanged;
    end

    function displaySizeListener:_Update()
        self:SetWantsUpdates(false);
        hunterDeadlyDecoyWindow:Redraw();
        UpdateScaleLabelAndBarFromScreenSize();
    end

    function displaySizeListener:_SizeChanged()
        if (self.ignoreSizeChangedEvents > 0) then
            self.ignoreSizeChangedEvents = self.ignoreSizeChangedEvents - 1;
            return;
        end
        self:SetSize(2, 2);
        self.ignoreSizeChangedEvents = 1;
        -- Need to wait until the next Update() cycle before reporting.
        self:SetWantsUpdates(true);
    end
end

function Main()
    LoadSettings();
    RegisterForUnload();
    DrawOptionsControl();
    DrawMainWindow();
    CreateDisplaySizeChangedNonsense();

    Turbine.Shell.WriteLine(GetString(_LANG.STATUS.LOADED));
end

Main();
