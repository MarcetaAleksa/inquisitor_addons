-- Create the main frame for the addon interface
local frame = CreateFrame("Frame", "DiceRollerFrame", UIParent, "BasicFrameTemplateWithInset")

-- untested code --
frame:SetMovaable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
-- the code below works properly only the above section should be removed if the addon crashes.

frame:SetSize(300, 200)  -- width, height
frame:SetPoint("CENTER") -- position
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("Dice Roller")

-- Edit box for entering the modifier
local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
editBox:SetPoint("TOP", frame, "TOP", 0, -30)
editBox:SetSize(100, 20)
editBox:SetAutoFocus(false)

-- Dropdown menu for selecting weapon type
local weaponDropdown = CreateFrame("Frame", "WeaponDropdown", frame, "UIDropDownMenuTemplate")
weaponDropdown:SetPoint("TOP", editBox, "BOTTOM", 0, -10)
UIDropDownMenu_SetWidth(weaponDropdown, 100)
UIDropDownMenu_SetText(weaponDropdown, "Select Weapon")

-- Populate dropdown with weapon types
local weapons = {
    { text = "One-Handed"},
    { text = "Two-Handed"},
    { text = "Magic"}
}

local function OnClick(self)
    UIDropDownMenu_SetSelectedID(weaponDropdown, self:GetID())
end

local function Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k, v in pairs(weapons) do
        info.text, info.arg1, info.func, info.checked = v.text, v.value, OnClick, false
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(weaponDropdown, Initialize)
UIDropDownMenu_SetSelectedID(weaponDropdown, 1)

-- Button for rolling the dice
local rollButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
rollButton:SetPoint("TOP", weaponDropdown, "BOTTOM", 0, -10)
rollButton:SetSize(100, 20)
rollButton:SetText("Roll")
rollButton:SetScript("OnClick", function()
    local modifier = tonumber(editBox:GetText())
    local weaponType = UIDropDownMenu_GetText(weaponDropdown)
    local damageDie=0
    if weaponType=="One-Handed" then 
      damageDie=8
    elseif weaponType=="Two-Handed" then
      damageDie=10
    elseif weaponType=="Magic" then
      damageDie=10
    end
    local roll = math.random(1, 100)
    local total = modifier + roll
    local success = total >= 100
    local critical = roll >= 95
    local damageRoll = 0

    print("Roll: " .. roll .. " + Modifier: " .. modifier .. " = Total: " .. total)
    if success == true then
        damageRoll = critical and (math.random(1, tonumber(damageDie)) + tonumber(damageDie)) or math.random(1, tonumber(damageDie))
        print("Success! " .. damageRoll)
    else
        print("Failure!")
    end
end)

-- Random number seed
math.randomseed(time())

-- Register the frame to be movable
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
