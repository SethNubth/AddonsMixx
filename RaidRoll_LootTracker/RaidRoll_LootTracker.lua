RaidRoll_LootTrackerLoaded=true

-- =========================================================
-- RaidRoll LootTracker v4.0 GOD EDITION - FULL COMPLETO
-- Fix: 1 espalda = 1 fila - Anti Dupe por Ventana
-- Fix: Rotface 294/299 + ToC/RS/Ulduar + WotLK Only
-- Author: GOD
-- =========================================================

local RR_LastLootMessageTime = 0
local ACCEPTED_ITEMS = { [46110]=true, [47556]=true, [45087]=true, [49908]=true }
local REJECTED_ITEMS = { [34057]=true, [36931]=true, [36919]=true, [36928]=true, [36934]=true, [36922]=true, [36925]=true, [47241]=true, [49426]=true }
local WOTLK_RAIDS = { [533]=true, [615]=true, [616]=true, [624]=true, [603]=true, [631]=true, [724]=true, [249]=true, [543]=true, [544]=true, [545]=true, [546]=true, [547]=true }

local strsplit_l = strsplit
local tonumber_l = tonumber
local GetTime_l = GetTime
local GetItemInfo_l = GetItemInfo

local function GetItemID(link)
    if not link then return 0 end
    local id = link:match("item:(%d+)")
    return tonumber_l(id) or 0
end

-- =========================================================
-- FIX GOD v4.0 - ANTI DUPE POR VENTANA
-- Si el ItemID ya existe en la ventana actual (<30seg), es DUPE
-- =========================================================
local function IsDupe(itemID)
    local db = RaidRoll_DB["Loot"]
    if not db then return false end
    local tw = db["TOTAL WINDOWS"]
    if not tw or tw == 0 then return false end
    if GetTime_l() - RR_LastLootMessageTime > 30 then return false end
    local win = db[tw]
    if not win or not win["TOTAL ITEMS"] or win["TOTAL ITEMS"]==0 then return false end
    for i=1, win["TOTAL ITEMS"] do
        local it = win["ITEM_"..i]
        if it and it.ITEMLINK and GetItemID(it.ITEMLINK) == itemID then
            return true
        end
    end
    return false
end

local function IsWotLKContent()
    if not RaidRoll_DBPC or not RaidRoll_DBPC[UnitName("player")] then return true end
    if not RaidRoll_DBPC[UnitName("player")]["RR_Frame_WotLK_Dung_Only"] then return true end
    local mapID = GetCurrentMapAreaID and GetCurrentMapAreaID() or 0
    if WOTLK_RAIDS[mapID] then return true end
    if IsInInstance() and UnitLevel("player")==80 then return true end
    return false
end

function RaidRoll_LootPanel_Setup()
    if not RaidRoll_LootPanel then return end
    local f = RaidRoll_LootPanel
    local function SetFont(fs, size) if GetLocale()=="zhCN" then fs:SetFont("Fonts\\ZYKai_T.TTF", size) else fs:SetFont("Fonts\\FRIZQT__.TTF", size) end end
    local t = f:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t:SetPoint("TopLeft", f, "TopLeft", 20, -10) t:SetJustifyH("LEFT") t:SetText("|cFFC41F3B"..RAIDROLL_LOCALE["OPTIONSTITLE"].." (Loot Window)") SetFont(t,16)
    local function CreateMsgEdit(idx, y1, y2)
        local s = f:CreateFontString(nil,"ARTWORK","GameFontNormal")
        s:SetPoint("TopLeft", f, "TOPLEFT", 10, y1) s:SetJustifyH("LEFT") s:SetText("|cFF69CCF0"..RAIDROLL_LOCALE["Set_Msg"..idx]) SetFont(s,14)
        local bf = CreateFrame("Frame","RR_Msg"..idx.."_FRAME",f)
        bf:SetBackdrop({bgFile="", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=false, tileSize=32, edgeSize=20, insets={left=2,right=2,top=2,bottom=2}})
        bf:SetWidth(390) bf:SetHeight(25) bf:SetPoint("TopLeft", f, "TOPLEFT", 10, y2)
        local eb = CreateFrame("EditBox", "Raid_Roll_SetMsg"..idx.."_EditBox", f, "InputBoxTemplate")
        SetFont(eb,14) eb:SetAutoFocus(false) eb:SetWidth(380) eb:SetHeight(20) eb:SetPoint("Left", bf, "Left",8,0)
        eb:SetScript("OnEditFocusLost", function() RaidRoll_DBPC[UnitName("player")]["Raid_Roll_SetMsg"..idx.."_EditBox"] = eb:GetText() end)
        eb:SetScript("OnChar", function() RaidRoll_DBPC[UnitName("player")]["Raid_Roll_SetMsg"..idx.."_EditBox"] = eb:GetText() end)
        eb:SetScript("OnEnterPressed", function() eb:ClearFocus() end)
        eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)
    end
    CreateMsgEdit(1,-50,-70) CreateMsgEdit(2,-100,-120) CreateMsgEdit(3,-150,-170)
    local t2 = f:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t2:SetPoint("TopLeft", f, "TopLeft", 15, -200) t2:SetJustifyH("LEFT") t2:SetText("|cFFFFFFFF"..RAIDROLL_LOCALE["Use_Item_Brackets"]) SetFont(t2,12)
    local t3 = f:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t3:SetPoint("TopLeft", f, "TopLeft", 20, -230) t3:SetJustifyH("LEFT") t3:SetText("|cFF2459FF"..RAIDROLL_LOCALE["General_Settings"]) SetFont(t3,16)
    local function CreateCheck(name, y, text)
        local cb = CreateFrame("CheckButton", name, f, "UICheckButtonTemplate")
        cb:SetWidth(20) cb:SetHeight(20) cb:SetPoint("TopLeft", f, "TopLeft", 30, y)
        if _G[name.."Text"] then _G[name.."Text"]:SetText("|cFFFFFFFF"..text) SetFont(_G[name.."Text"],12) end
        cb:SetScript("OnClick", RaidRoll_CheckButton_Update_Panel) return cb
    end
    CreateCheck("RR_AutoOpenLootWindow", -250, RAIDROLL_LOCALE["Automatically_open_window_when_new_loot_is_found"])
    CreateCheck("RR_ReceiveGuildMessages", -270, RAIDROLL_LOCALE["Receive_loot_messages_from_guild"])
    CreateCheck("RR_Enable3Messages", -290, RAIDROLL_LOCALE["RR_Enable3Messages"])
    local cb = CreateCheck("RR_Frame_WotLK_Dung_Only", -310, RAIDROLL_LOCALE["RR_WotLK_Dung_Only"])
    if cb then
        cb:SetScript("OnEnter", function(self) RR_MouseOverTooltip(self:GetName()) end)
        cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

function RR_DC() end

function RR_AddonMessageReceived(String, Channel)
    if Channel~="RAID" and Channel~="PARTY" then
        if Channel~="GUILD" then
            if not RaidRoll_DBPC[UnitName("player")] or not RaidRoll_DBPC[UnitName("player")]["RR_ReceiveGuildMessages"] then return end
        else return end
    end
    if not String then return end
    if not IsWotLKContent() then return end

    local Version = strsplit_l("\a", String, 2)
    if not Version then if time() >= (RR_LastItemDataReSent or 0)+5 then SendAddonMessage("RRL","Request","RAID") end return end
    if Version~="Alpha" and Version~="Beta_2" then return end

    local player_name, mob_name, ItemId, lootName, ItemLink, rarity, lootIcon, ItemLvl
    if Version=="Alpha" then
        local mob_guid, LootNumber
        Version, mob_guid, player_name, mob_name, LootNumber, ItemLink, rarity, lootIcon, lootName, ItemLvl = strsplit_l("\a", String, 11)
        ItemId = GetItemID(ItemLink)
        rarity = tonumber_l(rarity) or 0
    else
        Version, player_name, mob_name, ItemId, lootName, ItemLvl = strsplit_l("\a", String, 7)
        ItemId = tonumber_l(ItemId) or 0
        local _, link, r, lvl, _, _, _, _, _, icon = GetItemInfo_l(ItemId)
        ItemLink = link; rarity = r; ItemLvl = lvl; lootIcon = icon; rarity = tonumber_l(rarity) or 0
    end

    if not ItemId or ItemId==0 or not lootName then return end
    if REJECTED_ITEMS[ItemId] then return end
    if (rarity or 0) <=3 and not ACCEPTED_ITEMS[ItemId] and not (RaidRoll_DB and RaidRoll_DB["debug"]) then return end
    
    -- ANTI DUPE v4.0
    if IsDupe(ItemId) then return end

    local now = GetTime_l()
    if now > (RR_LastLootMessageTime + 30) then
        if RaidRoll_DBPC[UnitName("player")] and RaidRoll_DBPC[UnitName("player")]["RR_AutoOpenLootWindow"] and RR_LOOT_FRAME then RR_LOOT_FRAME:Show() end
        if RaidRoll_Loot_Slider then RaidRoll_Loot_Slider:SetValue(1) end
        RR_LastLootMessageTime = now
        RaidRoll_DB["Loot"]["TOTAL WINDOWS"] = (RaidRoll_DB["Loot"]["TOTAL WINDOWS"] or 0) + 1
        if RaidRoll_DB["Loot"]["CURRENT WINDOW"] == RaidRoll_DB["Loot"]["TOTAL WINDOWS"]-1 then
            RaidRoll_DB["Loot"]["CURRENT WINDOW"] = RaidRoll_DB["Loot"]["TOTAL WINDOWS"]
        end
    end

    local TotalWindows = RaidRoll_DB["Loot"]["TOTAL WINDOWS"]
    RaidRoll_DB["Loot"][TotalWindows] = RaidRoll_DB["Loot"][TotalWindows] or {}
    local win = RaidRoll_DB["Loot"][TotalWindows]
    win["LOOTER NAME"] = player_name
    win["MOB NAME"] = mob_name
    win["TOTAL ITEMS"] = (win["TOTAL ITEMS"] or 0) + 1
    local idx = win["TOTAL ITEMS"]
    win["ITEM_"..idx] = { LOOTNAME=lootName, ITEMLINK=ItemLink, ICON=lootIcon or "Interface\\Icons\\INV_Misc_QuestionMark", WINNER="-", RECEIVED="-", ITEMLEVEL=tonumber_l(ItemLvl) or 0 }

    RR_Loot_SortByItemLevel()
    RR_Loot_Display_Refresh()
end

function RR_Loot_SortByItemLevel()
    local tw = RaidRoll_DB["Loot"]["TOTAL WINDOWS"]
    if not tw or tw==0 then return end
    local win = RaidRoll_DB["Loot"][tw]
    if not win or not win["TOTAL ITEMS"] or win["TOTAL ITEMS"]<=1 then return end
    local n = win["TOTAL ITEMS"]
    local arr = {}
    for i=1,n do arr[i]=win["ITEM_"..i] end
    table.sort(arr, function(a,b) return (a.ITEMLEVEL or 0) > (b.ITEMLEVEL or 0) end)
    for i=1,n do win["ITEM_"..i]=arr[i] end
end

function RR_SetupLootFrame()
    if not RaidRoll_DB["Loot"] then RaidRoll_DB["Loot"]={} end
    RaidRoll_DB["Loot"]["TOTAL WINDOWS"]=RaidRoll_DB["Loot"]["TOTAL WINDOWS"] or 0
    RaidRoll_DB["Loot"]["CURRENT WINDOW"]=RaidRoll_DB["Loot"]["CURRENT WINDOW"] or 0
    if not RR_LOOT_FRAME then RR_LOOT_FRAME = CreateFrame("Frame","RR_LOOT_FRAME",UIParent) end
    local backdrop = { bgFile="Interface\\Addons\\RaidRoll\\Images\\Lich_King", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=false, tileSize=32, edgeSize=20, insets={left=2,right=2,top=2,bottom=2} }
    RR_LOOT_FRAME:SetBackdrop(backdrop)
    RR_LOOT_FRAME:SetFrameStrata("MEDIUM") RR_LOOT_FRAME:SetWidth(245) RR_LOOT_FRAME:SetHeight(290)
    RR_LOOT_FRAME:SetMovable(true) RR_LOOT_FRAME:EnableMouse(true)
    RR_LOOT_FRAME:SetScript("OnMouseDown", function() RR_LOOT_FRAME:StartMoving() end)
    RR_LOOT_FRAME:SetScript("OnMouseUp", function() RR_LOOT_FRAME:StopMovingOrSizing() end)
end

function RR_Loot_Display_Refresh()
    if not RaidRoll_DB or not RaidRoll_DB["Loot"] then return end
    local tw = RaidRoll_DB["Loot"]["TOTAL WINDOWS"]
    if not tw or tw==0 then return end
    if RaidRoll_LootTracker_Display then
        RaidRoll_LootTracker_Display()
    else
        if RR_LOOT_FRAME and RR_LOOT_FRAME:IsVisible() then
            -- fallback simple refresh
        end
    end
end

-- Frame de Display Base (si no existe)
if not RR_LOOT_FRAME then
    RR_LOOT_FRAME = CreateFrame("Frame","RR_LOOT_FRAME",UIParent)
    RR_LOOT_FRAME:SetPoint("CENTER",0,0)
    RR_LOOT_FRAME:Hide()
end

print("|cFF00FF00[RaidRoll LootTracker v4.0 FULL GOD]|r Anti-Dupe activo - 1 espalda = 1 fila")
