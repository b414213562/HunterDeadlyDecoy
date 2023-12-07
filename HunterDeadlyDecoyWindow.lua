HunterDeadlyDecoyWindow = class(Turbine.UI.Window);

function HunterDeadlyDecoyWindow:Constructor()
    Turbine.UI.Window.Constructor(self);

    screenWidth, screenHeight = Turbine.UI.Display:GetSize();

    self:SetPosition(
        SETTINGS.WINDOW.LEFT * screenWidth,
        SETTINGS.WINDOW.TOP * screenHeight);
    self:SetZOrder(0x0FFFFFFF);
    self.isUnlocked = false;

    self.imageControl = Turbine.UI.Control();
    self.imageControl:SetParent(self);
    self.imageControl:SetBackground("CubePlugins/HunterDeadlyDecoy/Resources/DeadlyDecoy.tga");

    self.timerText = Turbine.UI.Label();
    self.timerText:SetParent(self.imageControl);
    self.timerText:SetFont(Turbine.UI.Lotro.Font.LucidaConsole12);
    self.timerText:SetPosition(textMargin, textMargin);
    self.timerText:SetTextAlignment(Turbine.UI.ContentAlignment.BottomLeft);
    self.timerText:SetText("15");
    self.timerText:SetFontStyle(Turbine.UI.FontStyle.Outline);

    self.timerControl = Turbine.UI.Control();
    self.timerControl:SetParent(self);
    self.timerControl.BackColorStart = Turbine.UI.Color.White;
    self.timerControl.BackColorMiddle = Turbine.UI.Color.Yellow;
    self.timerControl.BackColorEnd = Turbine.UI.Color.Red;
    self.timerControl.startTime = 0;
    self.timerControl.previousUpdateTime = 0;
    self.timerControl.Update = function(sender, args)
        local currentTime = Turbine.Engine.GetGameTime();
        local deltaTime = currentTime - self.timerControl.startTime;
        local timeLeft = self.timerControl.expireTime - deltaTime;

        local isPrecise = timeLeft < 5;
        local updateInterval = .5;
        if (isPrecise) then updateInterval = .05; end

        if (deltaTime > self.timerControl.expireTime) then
            self:Hide();
        elseif (currentTime > (self.timerControl.previousUpdateTime + updateInterval)) then
            self.timerControl.previousUpdateTime = currentTime;
            local windowWidth = SETTINGS.WINDOW.WIDTH * screenWidth;
            local barWidth = windowWidth - (deltaTime / self.timerControl.expireTime * windowWidth);
            self.timerControl:SetWidth(barWidth);

            local precision = 0;
            if (isPrecise) then precision = 1; end

            local timeLeftRounded = string.format("%." .. precision .. "f", timeLeft);
            self.timerText:SetText(timeLeftRounded);

            if (timeLeft < self.timerControl.endTime) then
                -- Red / End
                self.timerControl:SetBackColor(self.timerControl.BackColorEnd);
            elseif (timeLeft < self.timerControl.middleTime) then
                -- Yellow / Middle
                self.timerControl:SetBackColor(self.timerControl.BackColorMiddle);
            end
        end
    end

    self.healthControl = Turbine.UI.Control();
    self.healthControl:SetParent(self);
    self.healthControl:SetBackColor(Turbine.UI.Color.LimeGreen);

    self:SetMouseVisible(false);
    self.imageControl:SetMouseVisible(false);
    self.timerText:SetMouseVisible(false);
    self.timerControl:SetMouseVisible(false);
    self.healthControl:SetMouseVisible(false);

    self.MouseDown = function(sender, args)
        self.mouseDown_MousePosition = { Turbine.UI.Display.GetMousePosition(); }
        self.mouseDown_WindowPosition = { self:GetPosition(); }
        self.isMouseDown = true;
    end

    self.MouseUp = function(sender, args)
        self.isMouseDown = false;
    end

    self.MouseMove = function(sender, args)
        if (self.isMouseDown) then
            local mouseDownX, mouseDownY = unpack(self.mouseDown_MousePosition);
            local windowLeft, windowTop = unpack(self.mouseDown_WindowPosition);
            local mouseCurrentX, mouseCurrentY = Turbine.UI.Display.GetMousePosition();

            -- calculate how much the cursor has moved
            local deltaX = mouseCurrentX - mouseDownX;
            local deltaY = mouseCurrentY - mouseDownY;

            -- move the window the same distance that the mouse has moved:
            self:SetPosition(windowLeft + deltaX, windowTop + deltaY);

            local screenWidth, screenHeight = Turbine.UI.Display:GetSize();
            SETTINGS.WINDOW.LEFT = self:GetLeft() / screenWidth;
            SETTINGS.WINDOW.TOP = self:GetTop() / screenHeight;

        end
    end

    self:Redraw();
end

-- Change size & position of each element based on current
-- SETTINGS.WINDOW.WIDTH and screen resolution.
function HunterDeadlyDecoyWindow:Redraw()
    screenWidth, screenHeight = Turbine.UI.Display:GetSize();
    local windowWidth = SETTINGS.WINDOW.WIDTH * screenWidth;

    local finalImageWidth = windowWidth;
    local finalImageHeight = windowWidth;
    local imageScaling = finalImageWidth / imageWidth;

    if (imageScaling < 0.5) then imageScaling = 0.5; end
    if (imageScaling > 10) then imageScaling = 10; end

    self:SetWidth(windowWidth);

    local textMargin = 2;
    self.timerText:SetWidth(imageWidth - textMargin * 2);
    self.timerText:SetHeight(imageHeight - textMargin * 2);

    self.imageControl:SetSize(imageWidth, imageHeight);

    local timerControlHeightPixels = 5;
    local timerControlHeight = imageScaling * timerControlHeightPixels;
    self.timerControl.maxWidth = windowWidth;
    self.timerControl:SetHeight(timerControlHeight);

    local timerControlTopMarginPixels = 4;
    local timerControlTopMargin = imageScaling * timerControlTopMarginPixels;
    local timerControlTop = finalImageHeight + timerControlTopMargin;
    self.timerControl:SetTop(timerControlTop);

    local healthControlHeightPixels = 5;
    local healthControlHeight = imageScaling * healthControlHeightPixels;
    self.healthControl.maxWidth = windowWidth;
    self.healthControl:SetSize(windowWidth, healthControlHeight);

    local healthControlTopMarginPixels = 1;
    local healthControlTopMargin = imageScaling * healthControlTopMarginPixels;
    local healthControlTop = 
        finalImageHeight + 
        timerControlTopMargin + 
        timerControlHeight + 
        healthControlTopMargin;
    self.healthControl:SetTop(healthControlTop);

    local windowHeight = healthControlTop + healthControlHeight;
    self:SetHeight(windowHeight);

    -- Stretch the image, make the rest bigger manually:
    self.imageControl:SetStretchMode(1);
    self.imageControl:SetSize(windowWidth, windowWidth);
    -- End stretch code
end

function HunterDeadlyDecoyWindow:UnlockForMoving()
    self.isUnlocked = true;
    self.timerControl:SetWidth(self.timerControl.maxWidth);
    self.timerText:SetText(15);
    self.healthControl:SetWidth(self.healthControl.maxWidth);

    self:SetVisible(true);
    self:SetMouseVisible(true);
end

function HunterDeadlyDecoyWindow:LockForMoving()
    self.isUnlocked = false;

    self:SetVisible(false);
    self:SetMouseVisible(false);
end

function HunterDeadlyDecoyWindow:Show(isDeadly)
    if (self.isUnlocked) then return; end

    self:SetVisible(true);

    self.timerControl:SetBackColor(self.timerControl.BackColorStart);
    self.timerControl:SetWidth(self.timerControl.maxWidth);
    self.timerControl.startTime = Turbine.Engine.GetGameTime();
    if (isDeadly) then
        self.timerControl.expireTime = 15;
        self.timerControl.middleTime = 10;
        self.timerControl.endTime = 5;
    else
        self.timerControl.expireTime = 60;
        self.timerControl.middleTime = 0;
        self.timerControl.endTime = 0;
    end
    self.timerControl:SetWantsUpdates(true);

    -- Get the max morale for decoy
    local currentLevel = localPlayer:GetLevel();
    local decoyMaxHealth = _DEADLY_DECOY_MAX_HEALTH_PER_CHAR_LEVEL[currentLevel];
    if (decoyMaxHealth == nil) then
        self.healthControl.decoyMaxHealth = 0;
        self.healthControl:SetWidth(0);
    else
        self.healthControl.decoyMaxHealth = decoyMaxHealth;
        self.healthControl.decoyCurrentHealth = decoyMaxHealth;
        self.healthControl:SetWidth(self.healthControl.maxWidth);
    end

end

function HunterDeadlyDecoyWindow:Hide()
    if (self.isUnlocked) then return; end

    self:SetVisible(false);
    self.timerControl:SetWantsUpdates(false);
end

function HunterDeadlyDecoyWindow:DecoyDamage(damageAmount)
    if (self.isUnlocked) then return; end

    if (self.healthControl.decoyMaxHealth == 0) then return; end

    self.healthControl.decoyCurrentHealth = 
        self.healthControl.decoyCurrentHealth - tonumber(damageAmount);

    if (self.healthControl.decoyCurrentHealth <= 0) then
        -- health is <= 0, decoy died :(
        self:Hide();
    else
        -- health is > 0, update bar
        local percent = 
            self.healthControl.decoyCurrentHealth / 
            self.healthControl.decoyMaxHealth;
        local barWidth = (percent * self.healthControl.maxWidth);
        self.healthControl:SetWidth(barWidth);
    end
end