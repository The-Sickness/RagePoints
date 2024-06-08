-- RagePoints
-- By: Sharpedge-Gaming
--Version: 1.05 11.0.0 Alpha Build
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AceAddon = LibStub("AceAddon-3.0"):NewAddon("RagePoints", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- Border options
local borderOptions = {
    { name = "Azerite", file = "Interface/Tooltips/UI-Tooltip-Border-Azerite" },
    { name = "Classic", file = "Interface/Tooltips/UI-Tooltip-Border" },
    { name = "Sleek", file = "Interface/DialogFrame/UI-DialogBox-Border" },
    { name = "Corrupted", file = "Interface/Tooltips/UI-Tooltip-Border-Corrupted" },
    { name = "Maw", file = "Interface/Tooltips/UI-Tooltip-Border-Maw" },   
    { name = "Glass", file = "Interface/DialogFrame/UI-DialogBox-TestWatermark-Border" },
    { name = "Gold", file = "Interface/DialogFrame/UI-DialogBox-Gold-Border" },
    { name = "Slide", file = "Interface/FriendsFrame/UI-Toast-Border" },
    { name = "Glow", file = "Interface/TutorialFrame/UI-TutorialFrame-CalloutGlow" },   
    { name = "Blue", file = "Interface/AddOns/RagePoints/Textures/BG1.png" },  
    { name = "Silverish", file = "Interface/AddOns/RagePoints/Textures/BG3.blp" },
    { name = "Fade", file = "Interface/AddOns/RagePoints/Textures/BG6.blp" },
    { name = "Fade 2", file = "Interface/AddOns/RagePoints/Textures/BG7.blp" },
    { name = "Thin Line", file = "Interface/AddOns/RagePoints/Textures/BG8.blp" },
    { name = "2 Tone", file = "Interface/AddOns/RagePoints/Textures/BG9.blp" },
    { name = "Bluish", file = "Interface/AddOns/RagePoints/Textures/BG10.blp" },
    { name = "Neon Yellow", file = "Interface/AddOns/RagePoints/Textures/BG11.blp" },
    { name = "Neon Red", file = "Interface/AddOns/RagePoints/Textures/BG12.blp" },
    { name = "Neon Green", file = "Interface/AddOns/RagePoints/Textures/BG13.blp" },
    { name = "Neon Blue", file = "Interface/AddOns/RagePoints/Textures/BG14.blp" },
    { name = "Double Yellow", file = "Interface/AddOns/RagePoints/Textures/BG16.blp" },
}

-- Default settings
local defaults = {
    position = {
        point = "CENTER",
        relativeTo = nil,
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 0
    },
    width = 200,
    height = 20,
    color = {r = 1, g = 0, b = 0, a = 1},
    displayFormat = "Absolute",
    showInCombat = false,
    enabled = true,
    barTexture = "Blizzard",
    locked = false,
    border = "Classic"
}

-- Initialize the database
local function InitializeDatabase()
    if not RagePointsDB or type(RagePointsDB) ~= "table" then
        RagePointsDB = CopyTable(defaults)
    end
    for k, v in pairs(defaults) do
        if RagePointsDB[k] == nil then
            RagePointsDB[k] = v
        end
    end
end

InitializeDatabase()

-- Create the frame
local RagePoints = CreateFrame("Frame", "RagePointsFrame", UIParent)
RagePoints:SetSize(RagePointsDB.width, RagePointsDB.height)
RagePoints:SetPoint(RagePointsDB.position.point, UIParent, RagePointsDB.position.relativePoint, RagePointsDB.position.xOfs, RagePointsDB.position.yOfs)
RagePoints:SetMovable(true)
RagePoints:EnableMouse(true)
RagePoints:RegisterForDrag("LeftButton")
RagePoints:SetScript("OnDragStart", function(self)
    if not RagePointsDB.locked then
        self:StartMoving()
    end
end)
RagePoints:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    RagePointsDB.position = {point = point, relativeTo = relativeTo, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs}
end)

-- Create the status bar with padding
local RageBar = CreateFrame("StatusBar", nil, RagePoints)
RageBar:SetPoint("TOPLEFT", RagePoints, "TOPLEFT", 2, -2)
RageBar:SetPoint("BOTTOMRIGHT", RagePoints, "BOTTOMRIGHT", -2, 2)
RageBar:SetStatusBarTexture(LSM:Fetch("statusbar", RagePointsDB.barTexture))
RageBar:GetStatusBarTexture():SetHorizTile(false)

-- Create a font string for the bar
local RageBarText = RageBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
RageBarText:SetPoint("CENTER", RageBar, "CENTER")

-- Function to create or update the border
local function UpdateRageBarBorder()
    if RagePoints.border then
        RagePoints.border:SetBackdrop(nil)
        RagePoints.border:Hide()
        RagePoints.border = nil
    end
    local borderFile
    for _, option in pairs(borderOptions) do
        if option.name == RagePointsDB.border then
            borderFile = option.file
            break
        end
    end
    if borderFile then
        local border = CreateFrame("Frame", nil, RagePoints, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = borderFile,
            edgeSize = 8,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        })
        border:SetPoint("TOPLEFT", RagePoints, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", RagePoints, "BOTTOMRIGHT", 1, -1)
        border:SetFrameLevel(RagePoints:GetFrameLevel() + 1)
        RagePoints.border = border
    end
end

-- Apply a visible border to the RageBar
UpdateRageBarBorder()

-- Function to check if the player is of an allowed class or specialization
local function IsAllowedClass()
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID = specIndex and GetSpecializationInfo(specIndex)

    local allowedClasses = {
        ["DEMONHUNTER"] = true,      
        ["WARRIOR"] = true,
    }

    if class == "DRUID" and specID == 103 then
        return true
    end

    return allowedClasses[class] or false
end

-- Function to check if the power type should be displayed as whole numbers
local function ShouldDisplayAsWholeNumbers(powerType)
    return powerType == Enum.PowerType.SoulShards or powerType == Enum.PowerType.HolyPower or
           powerType == Enum.PowerType.ComboPoints or powerType == Enum.PowerType.ArcaneCharges or
           powerType == Enum.PowerType.Chi or powerType == Enum.PowerType.Runes
end

-- Update the bar and text based on power type
local function UpdateRageBar()
    if not IsAllowedClass() then
        RagePoints:Hide()
        return
    end

    local powerType, powerToken = UnitPowerType("player")
    local power = UnitPower("player", powerType)
    local maxPower = UnitPowerMax("player", powerType)
    local format = RagePointsDB.displayFormat

    if ShouldDisplayAsWholeNumbers(powerType) then
        power = math.floor(power)
        maxPower = math.floor(maxPower)
    end

    RageBar:SetMinMaxValues(0, maxPower)
    RageBar:SetValue(power)
    if format == "Percentage" then
        RageBarText:SetText(string.format("%.1f%%", (power / maxPower) * 100))
    elseif format == "Combined" then
        RageBarText:SetText(string.format("%d / %d (%.1f%%)", power, maxPower, (power / maxPower) * 100))
    else
        RageBarText:SetText(string.format("%d / %d", power, maxPower))
    end
end

-- Function to update the RageBar color
local function UpdateRageBarColor()
    local c = RagePointsDB.color
    RageBar:SetStatusBarColor(c.r, c.g, c.b, c.a)
end

-- Function to update the RageBar texture
local function UpdateRageBarTexture()
    local texture = LSM:Fetch("statusbar", RagePointsDB.barTexture)
    RageBar:SetStatusBarTexture(texture)
end

-- Function to update the RageBar size
local function UpdateRageBarSize()
    RagePoints:SetWidth(RagePointsDB.width)
    RagePoints:SetHeight(RagePointsDB.height)
end

-- Show/Hide the bar based on combat state and settings
local function UpdateVisibility()
    if not IsAllowedClass() then
        RagePoints:Hide()
        return
    end

    if RagePointsDB.enabled then
        if RagePointsDB.showInCombat then
            if InCombatLockdown() then
                RagePoints:Show()
            else
                RagePoints:Hide()
            end
        else
            RagePoints:Show()
        end
    else
        RagePoints:Hide()
    end
end

-- Register events for visibility updates
RagePoints:RegisterEvent("PLAYER_REGEN_ENABLED")
RagePoints:RegisterEvent("PLAYER_REGEN_DISABLED")
RagePoints:RegisterEvent("PLAYER_ENTERING_WORLD")
RagePoints:RegisterEvent("UNIT_POWER_UPDATE")
RagePoints:RegisterEvent("UNIT_POWER_FREQUENT")
RagePoints:RegisterEvent("PLAYER_TARGET_CHANGED")
RagePoints:RegisterEvent("UNIT_HEALTH")
RagePoints:RegisterEvent("UNIT_MAXHEALTH")
RagePoints:RegisterEvent("UNIT_MAXPOWER")
RagePoints:RegisterEvent("CHARACTER_POINTS_CHANGED")
RagePoints:RegisterEvent("UNIT_DISPLAYPOWER")

RagePoints:SetScript("OnEvent", function(self, event, arg1, powerType)
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" then
        if not IsAllowedClass() then return end
        local currentPowerType = UnitPowerType("player")
        UpdateRageBar()
        UpdateRageBarColor()
        UpdateRageBarSize()
        UpdateRageBarTexture()
        UpdateRageBarBorder()
    elseif (event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT") and arg1 == "player" then
        UpdateRageBar()
    end
    UpdateVisibility()
end)

local LSM = LibStub("LibSharedMedia-3.0")

-- Configuration table
local options = {
    name = "RagePoints",
    handler = AceAddon,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = "General Settings",
            order = 1,
            inline = true,
            args = {
                enabled = {
                    type = 'toggle',
                    name = "Enable",
                    order = 1,
                    get = function() return RagePointsDB.enabled end,
                    set = function(_, val)
                        RagePointsDB.enabled = val
                        UpdateVisibility()
                    end
                },
                showInCombat = {
                    type = 'toggle',
                    name = "Show Only In Combat",
                    order = 2,
                    get = function() return RagePointsDB.showInCombat end,
                    set = function(_, val)
                        RagePointsDB.showInCombat = val
                        UpdateVisibility()
                    end
                },
                locked = {
                    type = 'toggle',
                    name = "Lock Frame",
                    order = 3,
                    get = function() return RagePointsDB.locked end,
                    set = function(_, val)
                        RagePointsDB.locked = val
                        RagePoints:EnableMouse(not val)
                    end
                }
            }
        },
        appearance = {
            type = 'group',
            name = "Appearance",
            order = 2,
            inline = true,
            args = {
                width = {
                    type = 'range',
                    name = "Bar Width",
                    order = 1,
                    min = 100,
                    max = 400,
                    step = 1,
                    get = function() return RagePointsDB.width end,
                    set = function(_, val)
                        RagePointsDB.width = val
                        UpdateRageBarSize()
                    end
                },
                height = {
                    type = 'range',
                    name = "Bar Height",
                    order = 2,
                    min = 10,
                    max = 40,
                    step = 1,
                    get = function() return RagePointsDB.height end,
                    set = function(_, val)
                        RagePointsDB.height = val
                        UpdateRageBarSize()
                    end
                },
                color = {
                    type = 'color',
                    name = "Bar Color",
                    order = 3,
                    hasAlpha = true,
                    get = function()
                        local c = RagePointsDB.color
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        RagePointsDB.color = {r = r, g = g, b = b, a = a}
                        UpdateRageBarColor()
                    end
                },
                displayFormat = {
                    type = 'select',
                    name = "Display Format",
                    order = 4,
                    values = {
                        Absolute = "Absolute",
                        Percentage = "Percentage",
                        Combined = "Combined",
                    },
                    get = function() return RagePointsDB.displayFormat end,
                    set = function(_, val)
                        RagePointsDB.displayFormat = val
                        UpdateRageBar(UnitPowerType("player"))
                    end,
                },
                barTexture = {
                    type = 'select',
                    name = "Bar Texture",
                    order = 5,
                    dialogControl = 'LSM30_Statusbar',
                    values = LSM:HashTable("statusbar"),
                    get = function() return RagePointsDB.barTexture end,
                    set = function(_, val)
                        RagePointsDB.barTexture = val
                        UpdateRageBarTexture()
                    end,
                },
                border = {
                    type = 'select',
                    name = "Border Style",
                    order = 6,
                    values = function()
                        local t = {}
                        for _, option in pairs(borderOptions) do
                            t[option.name] = option.name
                        end
                        return t
                    end,
                    get = function() return RagePointsDB.border end,
                    set = function(_, val)
                        RagePointsDB.border = val
                        UpdateRageBarBorder()
                    end,
                }
            }
        }
    }
}

-- Register options table using AceConfig
AceConfig:RegisterOptionsTable("RagePoints", options)
AceConfigDialog:AddToBlizOptions("RagePoints", "RagePoints")

-- Create the options panel frame for Interface Options
local optionsPanel = CreateFrame("Frame", "RagePointsOptionsPanel", UIParent)
optionsPanel.name = "RagePoints"
optionsPanel:Hide()

optionsPanel.title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsPanel.title:SetPoint("TOPLEFT", 16, -16)
optionsPanel.title:SetText("RagePoints")

optionsPanel.instructions = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optionsPanel.instructions:SetPoint("TOPLEFT", optionsPanel.title, "BOTTOMLEFT", 0, -8)
optionsPanel.instructions:SetWidth(300)
optionsPanel.instructions:SetJustifyH("LEFT")
optionsPanel.instructions:SetText("Here you can configure RagePoints to your liking.")

-- Register the options panel using the new Settings API, if available
if Settings then
    local function RegisterOptionsPanel(panel)
        local category = Settings.GetCategory(panel.name)
        if not category then
            category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            category.ID = panel.name
            Settings.RegisterAddOnCategory(category)
        end
    end

    -- Call the registration function
    RegisterOptionsPanel(optionsPanel)
else
    -- Fallback for older versions without the new Settings API
    InterfaceOptions_AddCategory(optionsPanel)
end

local function RagePoints_On_AddonLoaded()
    -- Load saved variables
    InitializeDatabase()

    -- Set the selected display format in the dropdown menu
    AceConfigRegistry:NotifyChange("RagePoints")
    UpdateRageBarColor()
    UpdateRageBarSize()
    UpdateRageBarTexture()
    UpdateRageBarBorder()
    UpdateVisibility()
end

optionsPanel:RegisterEvent("ADDON_LOADED")
optionsPanel:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "RagePoints" then
        RagePoints_On_AddonLoaded()
        optionsPanel:UnregisterEvent("ADDON_LOADED")
    end
end)

