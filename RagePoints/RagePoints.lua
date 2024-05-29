-- Embed Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0"):NewAddon("RagePoints", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- Default settings
local defaults = {
    profile = {
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
        displayFormat = "Absolute"
    }
}

-- Initialize the database
AceAddon.db = AceDB:New("RagePointsDB", defaults, true)

-- Create the frame
local RagePoints = CreateFrame("Frame", "RagePointsFrame", UIParent)
RagePoints:SetSize(AceAddon.db.profile.width, AceAddon.db.profile.height)
RagePoints:SetPoint(AceAddon.db.profile.position.point, UIParent, AceAddon.db.profile.position.relativePoint, AceAddon.db.profile.position.xOfs, AceAddon.db.profile.position.yOfs)
RagePoints:SetMovable(true)
RagePoints:EnableMouse(true)
RagePoints:RegisterForDrag("LeftButton")
RagePoints:SetScript("OnDragStart", RagePoints.StartMoving)
RagePoints:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    AceAddon.db.profile.position = {point = point, relativeTo = relativeTo, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs}
end)

-- Create the status bar
local RageBar = CreateFrame("StatusBar", nil, RagePoints)
RageBar:SetAllPoints(RagePoints)
RageBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
RageBar:GetStatusBarTexture():SetHorizTile(false)
RageBar:SetMinMaxValues(0, UnitPowerMax("player", SPELL_POWER_RAGE))
RageBar:SetValue(UnitPower("player", SPELL_POWER_RAGE))

-- Create a font string for the bar
local RageBarText = RageBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
RageBarText:SetPoint("CENTER", RageBar, "CENTER")
RageBarText:SetText(UnitPower("player", SPELL_POWER_RAGE))

-- Update the bar and text
local function UpdateRageBar()
    local rage = UnitPower("player", SPELL_POWER_RAGE)
    local maxRage = UnitPowerMax("player", SPELL_POWER_RAGE)
    local format = AceAddon.db.profile.displayFormat

    RageBar:SetMinMaxValues(0, maxRage)
    RageBar:SetValue(rage)
    if format == "Percentage" then
        RageBarText:SetText(string.format("%.1f%%", (rage / maxRage) * 100))
    elseif format == "Combined" then
        RageBarText:SetText(string.format("%d / %d (%.1f%%)", rage, maxRage, (rage / maxRage) * 100))
    else
        RageBarText:SetText(string.format("%d / %d", rage, maxRage))
    end
end

-- Register events
RagePoints:RegisterEvent("UNIT_POWER_UPDATE")
RagePoints:RegisterEvent("PLAYER_ENTERING_WORLD")
RagePoints:SetScript("OnEvent", UpdateRageBar)

-- Configuration table
local options = {
    name = "RagePoints",
    handler = AceAddon,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = "General Settings",
            args = {
                width = {
                    type = 'range',
                    name = "Bar Width",
                    min = 100,
                    max = 400,
                    step = 1,
                    get = function() return AceAddon.db.profile.width end,
                    set = function(_, val) 
                        AceAddon.db.profile.width = val
                        RagePoints:SetWidth(val)
                    end
                },
                height = {
                    type = 'range',
                    name = "Bar Height",
                    min = 10,
                    max = 40,
                    step = 1,
                    get = function() return AceAddon.db.profile.height end,
                    set = function(_, val) 
                        AceAddon.db.profile.height = val
                        RagePoints:SetHeight(val)
                    end
                },
                color = {
                    type = 'color',
                    name = "Bar Color",
                    get = function() 
                        local c = AceAddon.db.profile.color 
                        return c.r, c.g, c.b, c.a 
                    end,
                    set = function(_, r, g, b, a) 
                        local c = AceAddon.db.profile.color
                        c.r, c.g, c.b, c.a = r, g, b, a
                        RageBar:SetStatusBarColor(r, g, b, a)
                    end
                },
                displayFormat = {
                    type = 'select',
                    name = "Display Format",
                    values = {
                        Absolute = "Absolute",
                        Percentage = "Percentage",
                        Combined = "Combined",
                    },
                    get = function() return AceAddon.db.profile.displayFormat end,
                    set = function(_, val) 
                        AceAddon.db.profile.displayFormat = val
                        RagePoints_DisplayFormat = val
                        UpdateRageBar()
                    end,
                },
            }
        }
    }
}

-- Register options
AceConfig:RegisterOptionsTable("RagePoints", options)
AceConfigDialog:AddToBlizOptions("RagePoints", "RagePoints")

-- Initialize settings
RageBar:SetStatusBarColor(AceAddon.db.profile.color.r, AceAddon.db.profile.color.g, AceAddon.db.profile.color.b, AceAddon.db.profile.color.a)

-- Create the options panel frame for Interface Options
local optionsPanel = CreateFrame("Frame", "RagePointsOptionsPanel", UIParent)
optionsPanel.name = "RagePoints"
InterfaceOptions_AddCategory(optionsPanel)

optionsPanel.title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsPanel.title:SetPoint("TOPLEFT", 16, -16)
optionsPanel.title:SetText("RagePoints")

optionsPanel.instructions = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optionsPanel.instructions:SetPoint("TOPLEFT", optionsPanel.title, "BOTTOMLEFT", 0, -8)
optionsPanel.instructions:SetWidth(300)
optionsPanel.instructions:SetJustifyH("LEFT")
optionsPanel.instructions:SetText("Here you can configure RagePoints to your liking.")

-- Adding AceConfigDialog container to our panel
local AceContainer = AceConfigDialog:AddToBlizOptions("RagePoints", "RagePoints", nil)
AceContainer:SetParent(optionsPanel)
AceContainer:ClearAllPoints()
AceContainer:SetPoint("TOPLEFT", optionsPanel.instructions, "BOTTOMLEFT", -16, -16)
AceContainer:SetPoint("BOTTOMRIGHT", optionsPanel, "BOTTOMRIGHT", -16, 16)

local function RagePoints_On_AddonLoaded()
    -- Load saved variables
    RagePoints_DisplayFormat = AceAddon.db.profile.displayFormat

    -- Set the selected display format in the dropdown menu
    AceConfigRegistry:NotifyChange("RagePoints")
end

optionsPanel:RegisterEvent("ADDON_LOADED")
optionsPanel:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "RagePoints" then
        RagePoints_On_AddonLoaded()
        optionsPanel:UnregisterEvent("ADDON_LOADED")
    end
end)
