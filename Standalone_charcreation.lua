-- WoW Addon: Character Sheet UI
-- This script will create a simple frame where users can input character information, while keeping certain fields automatically calculated.

-- Variables and Frame Creation
local addonName, addonTable = ...
local CharacterSheetUI = CreateFrame("Frame", "CharacterSheetFrame", UIParent, "BasicFrameTemplateWithInset")
CharacterSheetUI:Hide()
CharacterSheetUI:SetSize(300, 1500)
CharacterSheetUI:SetPoint("CENTER", UIParent, "CENTER")
CharacterSheetUI.title = CharacterSheetUI:CreateFontString(nil, "OVERLAY")
CharacterSheetUI.title:SetFontObject("GameFontHighlightLarge")
CharacterSheetUI.title:SetPoint("TOP", CharacterSheetUI, "TOP", 0, -10)
CharacterSheetUI.title:SetText("Character Sheet")

-- Editable Fields
local editableFields = {
    { label = "Character Name", key = "characterName" },
    { label = "Experience Points", key = "xp" }
}

local attributeFields = {
    { label = "Strength", key = "strength", default = 10 },
    { label = "Dexterity", key = "dexterity", default = 10 },
    { label = "Endurance", key = "endurance", default = 10 },
    { label = "Instinct", key = "instinct", default = 10 },
    { label = "Will", key = "will", default = 10 }
}

local combatSkillFields = {
    { label = "Melee Combat", key = "meleeCombat", default = 0 },
    { label = "Ranged Combat", key = "rangedCombat", default = 0 },
    { label = "Battle Magic", key = "battleMagic", default = 0 },
    { label = "Abjuration Magic", key = "abjurationMagic", default = 0 },
    { label = "Battlefield Defense", key = "battlefieldDefenseSkill", default = 0 },
    { label = "Healing Magic", key = "healingMagic", default = 0 }
}

local specializedSkillFields = {
    { label = "Stealth", key = "specialSkill1", default = 0 },
    { label = "Perception", key = "specialSkill2", default = 0 },
    { label = "Animal Handling", key = "specialSkill3", default = 0 },
    { label = "Survival", key = "specialSkill4", default = 0 },
    { label = "Knowledge of Magic", key = "specialSkill5", default = 0 },
    { label = "Knowledge of Religion", key = "specialSkill6", default = 0 },
    { label = "Knowledge of Technology", key = "specialSkill7", default = 0 },
    { label = "Knowledge of Nature", key = "specialSkill8", default = 0 },
    { label = "Medicine", key = "specialSkill9", default = 0 }
}

-- Functions to Create Input and Dropdown Fields
local function CreateInputField(parent, label, yOffset)
    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    labelText:SetText(label .. ":")

    local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    editBox:SetSize(150, 20)
    editBox:SetPoint("LEFT", labelText, "RIGHT", 10, 0)
    editBox:SetAutoFocus(false)
    
    editBox:SetScript("OnTextChanged", function(self)
        local value = tonumber(self:GetText()) or 0
        if value < 0 then
            value = 0
            self:SetText(value)
        elseif value > 60 then
            value = 60
            self:SetText(value)
        end
        UpdateFormulas()
    end)

    return editBox
end

local function CreateDropdownField(parent, label, yOffset, options, key)
    local tooltipText = {
        archetype = "Choose your character's archetype, which affects various abilities and stats.",
        armorType = "Select the type of armor your character is wearing. This affects your damage reduction.",
        shield = "Select whether your character is using a shield. Shields provide additional defense.",
        magicalPotential = "Select your character's magical potential, which influences healing and magical power."
    }
    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    labelText:SetText(label .. ":")

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown.tooltipText = tooltipText[key]
    dropdown:SetPoint("LEFT", labelText, "RIGHT", -10, -5)
    dropdown:EnableMouse(true)
    dropdown:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    dropdown:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(options) do
            info.text = option
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, option)
                fields[key] = option
                UpdateFormulas()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end

-- Creating Fields
local fields = {}
local yOffset = -40

-- Editable Fields
for _, field in ipairs(editableFields) do
    fields[field.key] = CreateInputField(CharacterSheetUI, field.label, yOffset)
    yOffset = yOffset - 30
end

-- Dropdown Fields
fields["armorType"] = CreateDropdownField(CharacterSheetUI, "Armor Type", yOffset, { "None", "Light", "Medium", "Heavy" }, "armorType")
yOffset = yOffset - 30

fields["shield"] = CreateDropdownField(CharacterSheetUI, "Shield", yOffset, { "None", "Yes" }, "shield")
yOffset = yOffset - 30

fields["archetype"] = CreateDropdownField(CharacterSheetUI, "Archetype", yOffset, { "Martial - Fighter", "Martial - Ranger", "Martial - Frontliner", "Martial - Half-Caster", "Spell-Caster - Healer", "Spell-Caster - Magician", "Spell-Caster - Half-Martial" }, "archetype")
yOffset = yOffset - 30

fields["magicalPotential"] = CreateDropdownField(CharacterSheetUI, "Magical Potential", yOffset, { "None", "Low", "Medium", "High" }, "magicalPotential")
yOffset = yOffset - 30

-- Attribute Fields
for _, attribute in ipairs(attributeFields) do
    fields[attribute.key] = CreateInputField(CharacterSheetUI, attribute.label, yOffset)
    fields[attribute.key]:SetText(attribute.default)
    yOffset = yOffset - 30
end

-- Combat Skill Fields
for _, skill in ipairs(combatSkillFields) do
    fields[skill.key] = CreateInputField(CharacterSheetUI, skill.label, yOffset)
    fields[skill.key]:SetText(skill.default)
    yOffset = yOffset - 30
end

-- Specialized Skill Fields
for _, skill in ipairs(specializedSkillFields) do
    fields[skill.key] = CreateInputField(CharacterSheetUI, skill.label, yOffset)
    fields[skill.key]:SetText(skill.default)
    yOffset = yOffset - 30
end

-- Function to Highlight Incomplete Fields
local function HighlightIncompleteFields()
    local requiredFields = {"characterName", "archetype", "armorType", "shield", "magicalPotential"}
    for _, key in ipairs(requiredFields) do
        if not fields[key] or (fields[key].GetText and fields[key]:GetText() == "") or (UIDropDownMenu_GetSelectedValue(fields[key]) == nil) then
            if fields[key].SetBackdrop then
                fields[key]:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16})
                fields[key]:SetBackdropBorderColor(1, 0, 0)  -- Red border for incomplete fields
            elseif fields[key].SetFont then
                fields[key]:SetTextColor(1, 0, 0)  -- Red text for labels
            end
        else
            -- Reset border or color if field is filled
            if fields[key].SetBackdrop then
                fields[key]:SetBackdrop(nil)
            elseif fields[key].SetFont then
                fields[key]:SetTextColor(1, 1, 1)  -- Normal white text
            end
        end
    end
end

-- Function to Load Character Data
local function LoadCharacterData()
    if CharacterSheetData then
        for key, value in pairs(CharacterSheetData) do
            if fields[key] then
                if type(fields[key]) == "table" and fields[key].SetText then
                    fields[key]:SetText(value)  -- For input fields, set the text value
                elseif key == "archetype" or key == "armorType" or key == "shield" or key == "magicalPotential" then
                    UIDropDownMenu_SetSelectedValue(fields[key], value)  -- For dropdown fields, set the selected value
                end
            end
        end
    end
end

-- Function to Save Character Data
local function SaveCharacterData()
    local isSheetComplete = IsCharacterSheetComplete()
    CharacterSheetData = {
        isComplete = isSheetComplete
    }
    for key, field in pairs(fields) do
        if type(field) == "table" and field.GetText then
            CharacterSheetData[key] = field:GetText()  -- For input fields
        elseif key == "archetype" or key == "armorType" or key == "shield" or key == "magicalPotential" then
            CharacterSheetData[key] = UIDropDownMenu_GetSelectedValue(field)  -- For dropdowns
        end
    end

    -- Convert characterData to a string to save (example to print to the chat)
    local serializedData = ""
    for k, v in pairs(CharacterSheetData) do
        serializedData = serializedData .. k .. "=" .. tostring(v) .. "\n"
    end

    -- Example output to the chat window for demonstration purposes
    print("Character Data Saved:")
    print(serializedData)
end

-- Function to Show Character Sheet UI
local function ShowCharacterSheetUI()
    if not IsCharacterSheetComplete() then
        print("Reminder: Your character sheet is incomplete. Please fill in all required fields.")
    end
    CharacterSheetUI:Show()
end

-- Function to Check if Character Sheet is Complete
local function IsCharacterSheetComplete()
    local requiredFields = {"characterName", "archetype", "armorType", "shield", "magicalPotential"}
    for _, key in ipairs(requiredFields) do
        if not fields[key] or (fields[key].GetText and fields[key]:GetText() == "") or (UIDropDownMenu_GetSelectedValue(fields[key]) == nil) then
            return false
        end
    end
    return true
end

-- Button to Save Data
local saveButton = CreateFrame("Button", "SaveCharacterButton", CharacterSheetUI, "GameMenuButtonTemplate")
saveButton:SetPoint("BOTTOM", CharacterSheetUI, "BOTTOM", 0, 10)
saveButton:SetSize(100, 30)
saveButton:SetText("Save")
saveButton:SetNormalFontObject("GameFontNormalLarge")
saveButton:SetHighlightFontObject("GameFontHighlightLarge")

saveButton:SetScript("OnClick", function()
    SaveCharacterData()
    HighlightIncompleteFields()  -- Highlight incomplete fields to remind the player
    CharacterSheetUI:Hide()  -- Hide the character sheet after saving, assuming character creation is complete
end)

-- Function to Update Formulas
function UpdateFormulas()
    -- Placeholder: Add logic to update calculated fields based on user input
    -- For example, updating hit points, skill modifiers, etc.
    HighlightIncompleteFields()
end

-- Load Character Data on UI Load
LoadCharacterData()

-- Load Data Every Time the Addon Is Activated
CharacterSheetFrame:RegisterEvent("ADDON_LOADED")
CharacterSheetFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        LoadCharacterData()
    end
end)
