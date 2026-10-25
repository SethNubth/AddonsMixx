-- RaidRoll v4.4.15 FIX 30300 v6.0 GOD PACK - Main File
-- FIX: EPGP 15s lock, arg1 nil, GuildRoster spam, TOC 30300

-- Local cache para performance
local strsplit_l = strsplit
local tonumber_l = tonumber
local GetTime_l = GetTime
local UnitName_l = UnitName

-- Config antibug
local RR_EPGP_LastGuildRoster = 0
local RR_EPGP_GuildCache = 30

-- FIX: Función local para no repetir SetFont 100 veces
local function RR_SetFont(fs, size)
    if GetLocale() == "zhCN" then
        fs:SetFont("Fonts\\ZYKai_T.TTF", size)
    else
        fs:SetFont("Fonts\\FRIZQT__.TTF", size)
    end
end

-- =========================================================
-- PANEL SETUP OPTIMIZADO
-- =========================================================
function Setup_RR_Panel()
    RaidRoll_Panel = {}
    RaidRoll_Panel.panel = CreateFrame("Frame", "Raid Roll Panel", UIParent)
    RaidRoll_Panel.panel.name = "Raid Roll"
    InterfaceOptions_AddCategory(RaidRoll_Panel.panel)
    
    RaidRoll_PriorityPanel = CreateFrame("Frame", "Raid Roll Loot Panel", UIParent)
    RaidRoll_PriorityPanel.name = "Priority"
    RaidRoll_PriorityPanel.parent = "Raid Roll"
    InterfaceOptions_AddCategory(RaidRoll_PriorityPanel)
    
    if RaidRoll_LootTrackerLoaded == true then
        RaidRoll_LootPanel = CreateFrame("Frame", "Raid Roll Loot Panel", UIParent)
        RaidRoll_LootPanel.name = "Loot Window"
        RaidRoll_LootPanel.parent = "Raid Roll"
        InterfaceOptions_AddCategory(RaidRoll_LootPanel)
    end
    
    RaidRoll_Panel.panel:SetScript("OnShow", function()
        RR_GuildRankUpdate()
        RR_GetEPGPGuildData()
        if RaidRoll_LootTrackerLoaded == true then
            if Raid_Roll_SetMsg3_EditBox then Raid_Roll_SetMsg3_EditBox:SetCursorPosition(0) end
            if Raid_Roll_SetMsg2_EditBox then Raid_Roll_SetMsg2_EditBox:SetCursorPosition(0) end
            if Raid_Roll_SetMsg1_EditBox then Raid_Roll_SetMsg1_EditBox:SetCursorPosition(0) end
        end
    end)

    -- Helper para crear check rápido
    local function CreateCheck(parent, name, y, text, x)
        x = x or 30
        local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
        cb:SetWidth(20) cb:SetHeight(20)
        cb:SetPoint("TopLeft", parent, "TopLeft", x, y)
        _G[name.."Text"]:SetText("|cFFFFFFFF"..text)
        RR_SetFont(_G[name.."Text"], 12)
        cb:SetScript("OnClick", RaidRoll_CheckButton_Update_Panel)
        cb:SetScript("OnEnter", function(self) RR_MouseOverTooltip(self:GetName()) end)
        cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return cb
    end

    -- TITULOS
    local t = RaidRoll_Panel.panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -10)
    t:SetText("|cFFC41F3B"..RAIDROLL_LOCALE["OPTIONSTITLE"])
    RR_SetFont(t, 16)
    
    local t2 = RaidRoll_Panel.panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t2:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -40)
    t2:SetText("|cFF2459FF"..RAIDROLL_LOCALE["General_Settings"])
    RR_SetFont(t2, 16)

    -- CHECKS GENERAL
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_Unannounced_panel", -60, RAIDROLL_LOCALE["Catch_Unannounced_Rolls"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_AllRolls_panel", -80, RAIDROLL_LOCALE["Allow_all_rolls"])
    CreateCheck(RaidRoll_Panel.panel, "RaidRollCheckBox_ExtraRolls_panel", -100, RAIDROLL_LOCALE["Allow_Extra_Rolls"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_GuildAnnounce", -120, RAIDROLL_LOCALE["Announce_winner_to_guild"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_GuildAnnounce_Officer", -135, RAIDROLL_LOCALE["Use_officer_channel"], 40)
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_Auto_Announce", -60, RAIDROLL_LOCALE["Auto_Announce_Count"], 240)
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_Auto_Close", -80, RAIDROLL_LOCALE["Auto_Close_Window"], 240)
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_No_countdown", -100, RAIDROLL_LOCALE["No_countdown"], 240)
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_Multi_Rollers", -120, RAIDROLL_LOCALE["Multi_Rollers"], 240)

    -- DISPLAY SETTINGS
    local t3 = RaidRoll_Panel.panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t3:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -160)
    t3:SetText("|cFF2459FF"..RAIDROLL_LOCALE["Raid_Roll_Display_Settings"])
    RR_SetFont(t3, 16)
    
    CreateCheck(RaidRoll_Panel.panel, "RaidRollCheckBox_ShowRanks_panel", -180, RAIDROLL_LOCALE["Show_Rank_Beside_Name"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_ShowGroupNumber_panel", -200, RAIDROLL_LOCALE["Show_Group_Beside_Name"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_ShowClassColors_panel", -180, RAIDROLL_LOCALE["Show_Class_Colors"], 240)

    -- EPGP SETTINGS
    local t4 = RaidRoll_Panel.panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t4:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -230)
    t4:SetText("|cFF2459FF"..RAIDROLL_LOCALE["Raid_Roll_EPGP_Settings"])
    RR_SetFont(t4, 16)
    
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_EPGPMode_panel", -250, RAIDROLL_LOCALE["Enable_EPGP_mode"])
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_EPGPThreshold_panel", -265, RAIDROLL_LOCALE["Enable_threshold_levels"], 40)
    CreateCheck(RaidRoll_Panel.panel, "RR_RollCheckBox_Enable_Alt_Mode", -280, RAIDROLL_LOCALE["Enable_Alt_Mode"], 40)
end

-- =========================================================
-- EPGP FIX 15s - ANTIBUG
-- =========================================================
function RR_GetEPGPGuildData()
    if RaidRoll_DB["EPGP"] == nil then RaidRoll_DB["EPGP"] = {} end
    if RaidRoll_DB["DECAY_P"] == nil then RaidRoll_DB["DECAY_P"] = 0 end
    if RaidRoll_DB["EXTRAS_P"] == nil then RaidRoll_DB["EXTRAS_P"] = 0 end
    if RaidRoll_DB["MIN_EP"] == nil then RaidRoll_DB["MIN_EP"] = 2500 end
    if RaidRoll_DB["BASE_GP"] == nil then RaidRoll_DB["BASE_GP"] = 1 end
    if RR_EPGPHasLoaded == true then
        RR_ReallyGetEPGPGuildData()
    end
end

function RR_GetEPGPCharacterData(character)
    local PR, AboveThreshold, EP, GP = 0, false, 0, 0
    if RR_EPGPHasLoaded == true then
        PR,AboveThreshold,EP,GP = RR_ReallyGetEPGPCharacterData(character)
    end
    return PR,AboveThreshold,EP,GP
end

function RR_EPGP_Setup()
    if RR_EPGPHasLoaded == true then
        local EPGP_Event = CreateFrame("Frame")
        EPGP_Event:RegisterEvent("CHAT_MSG_RAID")
        EPGP_Event:RegisterEvent("CHAT_MSG_OFFICER")
        EPGP_Event:RegisterEvent("CHAT_MSG_GUILD")
        EPGP_Event:RegisterEvent("CHAT_MSG_ADDON")
        EPGP_Event:SetScript("OnEvent", EPGP_Event_Function)
    end
end

function EPGP_Event_Function(self, event, ...)
    local arg1 = ...
    if not arg1 or type(arg1) ~= "string" then return end
    if not arg1:lower():find("epgp", 1, true) then return end
    
    local now = GetTime_l()
    if now - RR_EPGP_LastGuildRoster < RR_EPGP_GuildCache then return end
    RR_EPGP_LastGuildRoster = now
    
    if IsInGuild() then
        RR_GetEPGPGuildData()
    end
end

function RR_DC() end -- dummy para
