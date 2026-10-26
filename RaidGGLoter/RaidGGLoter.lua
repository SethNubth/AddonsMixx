RaidGGLoterDB = RaidGGLoterDB or { ["Loot"] = { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 } }
if not RaidRoll_DB then RaidRoll_DB = { ["Loot"] = { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 } } end
RaidRoll_DB["Loot"] = RaidRoll_DB["Loot"] or { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 }

-- ========== CONFIG ==========
local seen = {}
local LastLootTime = 0
local LastMsgTime = 0
local LastMob = ""

local function GetID(link) if not link then return 0 end return tonumber(link:match("item:(%d+)")) or 0 end

local function IsDupe(itemID, mob)
    local now = GetTime()
    local key = (mob or "Unknown").."_"..itemID
    if seen[key] and now - seen[key] < 15 then return true end
    seen[key] = now
    -- limpieza cada 2 min
    if now - LastLootTime > 120 then
        for k,v in pairs(seen) do if now - v > 130 then seen[k]=nil end end
        LastLootTime = now
    end
    return false
end

-- ========== FRAME ==========
RR_LOOT_FRAME = RR_LOOT_FRAME or CreateFrame("Frame", "RR_LOOT_FRAME", UIParent)
RR_LOOT_FRAME:SetSize(430, 320)
RR_LOOT_FRAME:SetPoint("CENTER", 0, 50)
RR_LOOT_FRAME:SetBackdrop({bgFile="Interface\\Addons\\RaidRoll\\Images\\Lich_King", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=false, tileSize=32, edgeSize=16, insets={left=3,right=3,top=3,bottom=3}})
RR_LOOT_FRAME:SetMovable(true)
RR_LOOT_FRAME:EnableMouse(true)
RR_LOOT_FRAME:RegisterForDrag("LeftButton")
RR_LOOT_FRAME:SetScript("OnDragStart", function(self) self:StartMoving() end)
RR_LOOT_FRAME:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
RR_LOOT_FRAME:Hide()

local title = RR_LOOT_FRAME:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("Musou's Loot Tracker |cFFFFD700[RaidGGLoter]|r")

local header = RR_LOOT_FRAME:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", 10, -35)
header:SetText("|cFF00FF00ITEM                                     WIN:                    LOOTER:|r")

-- 6 Lineas
local lines = {}
for i=1,6 do
    local f = CreateFrame("Button", nil, RR_LOOT_FRAME)
    f:SetSize(410, 38)
    f:SetPoint("TOPLEFT", 10, -50 - (i-1)*42)
    
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(32,32)
    f.icon:SetPoint("LEFT", 0, 0)
    
    f.item = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.item:SetPoint("LEFT", 35, 8)
    f.item:SetWidth(150)
    f.item:SetJustifyH("LEFT")
    
    f.win = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.win:SetPoint("LEFT", 180, 8)
    f.win:SetWidth(120)
    f.win:SetJustifyH("LEFT")
    
    f.looter = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.looter:SetPoint("LEFT", 305, 8)
    f.looter:SetWidth(110)
    f.looter:SetJustifyH("LEFT")
    
    f:Hide()
    lines[i]=f
end

function RR_Loot_Display_Refresh()
    local db = RaidRoll_DB["Loot"]
    local tw = db["TOTAL WINDOWS"]
    if not tw or tw==0 then return end
    local cw = db["CURRENT WINDOW"]
    if cw==0 then cw=tw end
    local win = db[cw]
    if not win then return end
    
    for i=1,6 do lines[i]:Hide() end
    
    for i=1, (win["TOTAL ITEMS"] or 0) do
        if i<=6 then
            local it = win["ITEM_"..i]
            if it then
                lines[i].icon:SetTexture(it.ICON or "Interface\\Icons\\INV_Misc_QuestionMark")
                lines[i].item:SetText(it.ITEMLINK or it.LOOTNAME)
                
                -- WIN: Pepito 19
                if it.WINNER and it.WINNER~="-" then
                    lines[i].win:SetText("|cFFFFD700Win: "..it.WINNER.."|r")
                else
                    lines[i].win:SetText("|cFF888888Win: -|r")
                end
                
                -- LOOTER: Musou 21:45
                if it.LOOTER and it.LOOTER~="-" then
                    lines[i].looter:SetText("|cFF00FF00"..it.LOOTER.."|r")
                else
                    lines[i].looter:SetText("|cFF888888En cadáver|r")
                end
                
                lines[i]:Show()
            end
        end
    end
    RR_LOOT_FRAME:Show()
end

function RR_Loot_SortByItemLevel() end -- compatibilidad

-- ========== SCAN REAL (SI VES CADAVER) ==========
local function AddNewWindow(mobb)
    local db = RaidRoll_DB["Loot"]
    local now = GetTime()
    if now > LastMsgTime + 30 then
        db["TOTAL WINDOWS"] = db["TOTAL WINDOWS"]+1
        db["CURRENT WINDOW"] = db["TOTAL WINDOWS"]
        db[db["TOTAL WINDOWS"]] = { ["MOB NAME"]=mobb, ["TOTAL ITEMS"]=0, ["LOOTER NAME"]=UnitName("player") }
        LastMsgTime = now
        return db[db["TOTAL WINDOWS"]]
    else
        return db[db["TOTAL WINDOWS"]]
    end
end

local function ScanRealLoot()
    if GetNumLootItems()==0 then return end
    local mob = UnitName("target") or "Boss"
    if mob=="Unknown" or not mob then mob = LastMob or "Boss" end
    LastMob = mob
    
    local db = RaidRoll_DB["Loot"]
    local curWin = AddNewWindow(mob)
    
    for slot=1, GetNumLootItems() do
        local _, lootName, _, rarity = GetLootSlotInfo(slot)
        local link = GetLootSlotLink(slot)
        if link and lootName then
            local id = GetID(link)
            if id~=0 and (rarity>=4 or id==47241) then
                if not IsDupe(id, mob) then
                    curWin["TOTAL ITEMS"] = curWin["TOTAL ITEMS"]+1
                    local idx = curWin["TOTAL ITEMS"]
                    local _, _, _, lvl, _, _, _, _, _, icon = GetItemInfo(id)
                    curWin["ITEM_"..idx] = {
                        LOOTNAME=lootName,
                        ITEMLINK=link,
                        ICON=icon or "Interface\\Icons\\INV_Misc_QuestionMark",
                        ITEMLEVEL=lvl or 0,
                        WINNER="-",
                        LOOTER="-",
                        RECEIVED="-",
                        ROLL=0
                    }
                end
            end
        end
    end
    RR_Loot_Display_Refresh()
end

-- ========== ROLL TRACK: Win: Pepito 19 ==========
local function TrackRoll(msg)
    local player, roll
    -- ES: "Pepito tira dados (1-100) y saca 19"
    player = msg:match("^(.-) tira dados")
    roll = msg:match("saca (%d+)")
    -- EN
    if not player then
        player = msg:match("^(.-) rolls")
        roll = msg:match("rolls (%d+)")
        if not roll then roll = msg:match("(%d+)%s*%(") end
    end
    if player and roll then
        roll = tonumber(roll)
        local db = RaidRoll_DB["Loot"]
        local tw = db["TOTAL WINDOWS"]
        if not tw or tw==0 then return end
        local win = db[db["CURRENT WINDOW"] or tw]
        if not win then return end
        
        -- Asigna al item sin ganador con roll más alto
        local bestIdx, bestRoll = nil, 0
        for i=1, (win["TOTAL ITEMS"] or 0) do
            local it = win["ITEM_"..i]
            if it and (it.ROLL or 0) < roll then
                if (it.ROLL or 0) >= bestRoll then
                    bestIdx = i
                    bestRoll = it.ROLL or 0
                end
            end
        end
        -- Si no hay best, agarra el primero sin winner
        if not bestIdx then
            for i=1, (win["TOTAL ITEMS"] or 0) do
                if win["ITEM_"..i].WINNER=="-" then bestIdx=i break end
            end
        end
        
        if bestIdx then
            local it = win["ITEM_"..bestIdx]
            if roll > (it.ROLL or 0) then
                it.WINNER = player.." "..roll
                it.ROLL = roll
                print("|cFFFFD700[RaidGGLoter]|r Win: "..it.WINNER.." -> "..it.LOOTNAME)
                RR_Loot_Display_Refresh()
            end
        end
    end
end

-- ========== LOOTER TRACK: Quien recogió primero ==========
local function TrackLooter(msg)
    local player, link
    if msg:find("Recibes botín") or msg:find("You receive") then
        player = UnitName("player")
        link = msg:match("|Hitem:.-|h")
    else
        player = msg:match("^(.-) recibe botín:") or msg:match("^(.-) receives loot:")
        link = msg:match("|Hitem:.-|h")
    end
    if player and link then
        local id = GetID(link)
        local db = RaidRoll_DB["Loot"]
        local tw = db["TOTAL WINDOWS"]
        if not tw or tw==0 then return end
        local win = db[db["CURRENT WINDOW"] or tw]
        if not win then return end
        
        for i=1, (win["TOTAL ITEMS"] or 0) do
            local it = win["ITEM_"..i]
            if it and GetID(it.ITEMLINK)==id and it.LOOTER=="-" then
                it.LOOTER = player.." "..date("%H:%M")
                it.RECEIVED = date("%H:%M:%S")
                print("|cFF00FF00[RaidGGLoter]|r Looter: "..player.." recogió "..link)
                RR_Loot_Display_Refresh()
                return
            end
        end
    end
end

-- ========== EVENTOS ==========
local ev = CreateFrame("Frame")
ev:RegisterEvent("LOOT_OPENED")
ev:RegisterEvent("CHAT_MSG_SYSTEM")
ev:RegisterEvent("CHAT_MSG_LOOT")
ev:SetScript("OnEvent", function(_, e, a1)
    if e=="LOOT_OPENED" then ScanRealLoot()
    elseif e=="CHAT_MSG_SYSTEM" then TrackRoll(a1)
    elseif e=="CHAT_MSG_LOOT" then TrackLooter(a1)
    end
end)

-- Slash
SLASH_GGLOTER1="/ggloter"
SLASH_GGLOTER2="/lootgg"
SlashCmdList["GGLOTER"]=function() if RR_LOOT_FRAME:IsShown() then RR_LOOT_FRAME:Hide() else RR_LOOT_FRAME:Show() RR_Loot_Display_Refresh() end end

print("|cFFFFD700[RaidGGLoter] v1.0 God Edition cargado. /ggloter|r")
