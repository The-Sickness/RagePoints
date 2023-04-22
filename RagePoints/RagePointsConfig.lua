local optionsPanel = CreateFrame("Frame", "RagePointsOptionsPanel", UIParent);
optionsPanel.name = "RagePoints";
InterfaceOptions_AddCategory(optionsPanel);

optionsPanel.title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
optionsPanel.title:SetPoint("TOPLEFT", 16, -16);
optionsPanel.title:SetText("RagePoints");

optionsPanel.instructions = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
optionsPanel.instructions:SetPoint("TOPLEFT", optionsPanel.title, "BOTTOMLEFT", 0, -8);
optionsPanel.instructions:SetWidth(300);
optionsPanel.instructions:SetJustifyH("LEFT");
optionsPanel.instructions:SetText("Here you can configure RagePoints to your liking.");

optionsPanel.displayFormatDropdown = CreateFrame("Frame", "RagePointsDisplayFormatDropdown", optionsPanel, "UIDropDownMenuTemplate");
optionsPanel.displayFormatDropdown:SetPoint("TOPLEFT", optionsPanel.instructions, "BOTTOMLEFT", -16, -24);

local function OnDisplayFormatSelected(self)
    UIDropDownMenu_SetSelectedID(optionsPanel.displayFormatDropdown, self:GetID());
    RagePoints_DisplayFormat = self.value;
end

local displayFormatOptions = {
    {text = "Absolute", value = "Absolute", func = OnDisplayFormatSelected},
    {text = "Percentage", value = "Percentage", func = OnDisplayFormatSelected},
    {text = "Combined", value = "Combined", func = OnDisplayFormatSelected}
};

UIDropDownMenu_SetWidth(optionsPanel.displayFormatDropdown, 180);
UIDropDownMenu_Initialize(optionsPanel.displayFormatDropdown, function(self, level)
    for _, option in ipairs(displayFormatOptions) do
        local info = UIDropDownMenu_CreateInfo();
        info.text = option.text;
        info.value = option.value;
        info.func = option.func;
        UIDropDownMenu_AddButton(info);
    end
end);

optionsPanel.displayFormatLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
optionsPanel.displayFormatLabel:SetPoint("BOTTOMLEFT", optionsPanel.displayFormatDropdown, "TOPLEFT", 16, 3);
optionsPanel.displayFormatLabel:SetText("Display Format:");

local function RagePoints_OnAddonLoaded()
    -- Load saved variables
    if not RagePoints_DisplayFormat then
        RagePoints_DisplayFormat = "Absolute"; -- Default value
    end

    -- Set the selected display format in the dropdown menu
    for index, option in ipairs(displayFormatOptions) do
        if option.value == RagePoints_DisplayFormat then
            UIDropDownMenu_SetSelectedID(optionsPanel.displayFormatDropdown, index);
            break;
        end
    end
end

local function RagePoints_On_AddonLoaded()
    -- Load saved variables
    if not RagePoints_DisplayFormat then
        RagePoints_DisplayFormat = "Absolute"; -- Default value
    end

    -- Set the selected display format in the dropdown menu
    for index, option in ipairs(displayFormatOptions) do
        if option.value == RagePoints_DisplayFormat then
            UIDropDownMenu_SetSelectedID(optionsPanel.displayFormatDropdown, index);
            break;
        end
    end
end


optionsPanel:RegisterEvent("ADDON_LOADED");
optionsPanel:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "RagePoints" then
        RagePoints_On_AddonLoaded();
        optionsPanel:UnregisterEvent("ADDON_LOADED");
    end
end);


