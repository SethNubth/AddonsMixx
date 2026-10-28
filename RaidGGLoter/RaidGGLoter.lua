-- RaidGGLoter v4.1 GOD - INF BANDA
-- Basado en tu RaidGGLoter v1.1 + fix Anti-Dupe v4.0 + botones

RaidRoll_DB = RaidRoll_DB or { ["Loot"] = { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 } }
RaidRoll_DB["Loot"] = RaidRoll_DB["Loot"] or { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 }

local seen, LastMsgTime = {}, 0
local function GetID(link) if not link then return 0 end return tonumber(link:match("item:(%d+)")) or 0 end

-- FRAME PRINCIPAL RaidGGLoter
if not RR_LOOT_FRAME then RR_LOOT_FRAME = CreateFrame("Frame", "RR_LOOT_FRAME", UIParent) end
RR_LOOT_FRAME:SetSize(430, 340)
RR_LOOT_FRAME:SetPoint("CENTER",0,50)
RR_LOOT_FRAME:SetBackdrop({bgFile="Interface\\DialogBox\\UI-DialogBox-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=32, edgeSize=16, insets={left=4,right=4,top=4,bottom=4}})
RR_LOOT_FRAME:SetMovable(true) RR_LOOT_FRAME:EnableMouse(true) RR_LOOT_FRAME:RegisterForDrag("LeftButton")
RR_LOOT_FRAME:SetScript("OnDragStart", function(s) s:StartMoving() end)
RR_LOOT_FRAME:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)
RR_LOOT_FRAME:Hide()

local title = RR_LOOT_FRAME:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOP",0,-10) title:SetText("|cFFFFD700RaidGGLoter v4.1 INF BANDA|r")

local lines = {}
for i=1,6 do
    local f = CreateFrame("Button", nil, RR_LOOT_FRAME)
    f:SetSize(410,36) f:SetPoint("TOPLEFT",10,-40-(i-1)*40)
    f.icon = f:CreateTexture(nil,"ARTWORK") f.icon:SetSize(32,32) f.icon:SetPoint("LEFT",0,0)
    f.item = f:CreateFontString(nil,"OVERLAY","GameFontNormal") f.item:SetPoint("LEFT",35,8) f.item:SetWidth(150) f.item:SetJustifyH("LEFT")
    f.win = f:CreateFontString(nil,"OVERLAY","GameFontNormal") f.win:SetPoint("LEFT",180,8) f.win:SetWidth(120) f.win:SetJustifyH("LEFT")
    f.looter = f:CreateFontString(nil,"OVERLAY","GameFontNormal") f.looter:SetPoint("LEFT",305,8) f.looter:SetWidth(110) f.looter:SetJustifyH("LEFT")
    f:Hide() lines[i]=f
end

function RR_Loot_Display_Refresh()
    local db = RaidRoll_DB["Loot"] if not db["TOTAL WINDOWS"] or db["TOTAL WINDOWS"]==0 then return end
    local win = db[db["CURRENT WINDOW"] or db["TOTAL WINDOWS"]] if not win then return end
    for i=1,6 do lines[i]:Hide() end
    for i=1,(win["TOTAL ITEMS"] or 0) do
        if i<=6 then
            local it = win["ITEM_"..i] if it then
                lines[i].icon:SetTexture(it.ICON or "Interface\\Icons\\INV_Misc_QuestionMark")
                lines[i].item:SetText(it.ITEMLINK or it.LOOTNAME)
                lines[i].win:SetText(it.WINNER~="-" and "|cFFFFD700🏆 "..it.WINNER.."|r" or "|cFF888888🏆 -|r")
                lines[i].looter:SetText(it.LOOTER~="-" and "|cFF00FF00🎒 "..it.LOOTER.."|r" or "|cFF888888🎒 -|r")
                lines[i]:Show()
            end
        end
    end
    RR_LOOT_FRAME:Show()
end

local function AddWindow(mob)
    local db = RaidRoll_DB["Loot"] local now=GetTime()
    if now > LastMsgTime+30 or db["TOTAL WINDOWS"]==0 then
        db["TOTAL WINDOWS"]=db["TOTAL WINDOWS"]+1 db["CURRENT WINDOW"]=db["TOTAL WINDOWS"]
        db[db["TOTAL WINDOWS"]] = {["MOB NAME"]=mob, ["TOTAL ITEMS"]=0} LastMsgTime=now
        return db[db["TOTAL WINDOWS"]]
    else return db[db["TOTAL WINDOWS"]] end
end

local function ScanLoot()
    if GetNumLootItems()==0 then return end
    local mob = UnitName("target") or "Boss"
    local cur = AddWindow(mob)
    if not cur then return end
    cur["TOTAL ITEMS"] = 0
    for slot=1,GetNumLootItems() do
        if LootSlotIsItem(slot) then
            local icon, name, quantity, rarity, locked = GetLootSlotInfo(slot)
            local link = GetLootSlotLink(slot)
            local id = GetID(link)
            if id ~= 0 then
                local k = mob.."_"..id
                if not (seen[k] and GetTime()-seen[k] < 15) then
                    seen[k]=GetTime()
                    cur["TOTAL ITEMS"] = cur["TOTAL ITEMS"] + 1
                    local idx = cur["TOTAL ITEMS"]
                    cur["ITEM_"..idx] = {
                        ITEMLINK = link or name, LOOTNAME = name, ICON = icon, WINNER = "-", LOOTER = UnitName("player"), ITEMID = id
                    }
                end
            end
        end
    end
    RR_Loot_Display_Refresh()
end

-- BOTONES INF BANDA
local function GetChannel() if IsInRaid() then return "RAID" elseif IsInGroup() then return "PARTY" else return "SAY" end end

local btnRaid = CreateFrame("Button", nil, RR_LOOT_FRAME, "GameMenuButtonTemplate")
btnRaid:SetSize(105, 28) btnRaid:SetPoint("BOTTOMLEFT", 10, 10) btnRaid:SetText("|cFF00FF00INF RAID|r")
btnRaid:SetScript("OnClick", function()
    local db = RaidRoll_DB["Loot"] local win = db[db["CURRENT WINDOW"]] if not win then return end
    local ch = GetChannel()
    SendChatMessage("=== RaidGGLoter: "..(win["MOB NAME"] or "Boss").." ===", ch)
    for i=1,(win["TOTAL ITEMS"] or 0) do
        local it = win["ITEM_"..i] if it and it.ITEMLINK then SendChatMessage(i..". "..it.ITEMLINK, ch) end
    end
end)

local btnBanda = CreateFrame("Button", nil, RR_LOOT_FRAME, "GameMenuButtonTemplate")
btnBanda:SetSize(105, 28) btnBanda:SetPoint("BOTTOM", 0, 10) btnBanda:SetText("|cFFFFD700INF BANDA|r")
btnBanda:SetScript("OnClick", function()
    local db = RaidRoll_DB["Loot"] local win = db[db["CURRENT WINDOW"]] if not win then return end
    local ch = GetChannel()
    for i=1,(win["TOTAL ITEMS"] or 0) do
        local it = win["ITEM_"..i] if it then
            local w = it.WINNER ~= "-" and it.WINNER or "Sin asignar"
            SendChatMessage((it.ITEMLINK or it.LOOTNAME).." -> Ganador: "..w, ch)
        end
    end
end)

local btnClose = CreateFrame("Button", nil, RR_LOOT_FRAME, "GameMenuButtonTemplate")
btnClose:SetSize(90, 28) btnClose:SetPoint("BOTTOMRIGHT", -10, 10) btnClose:SetText("CERRAR")
btnClose:SetScript("OnClick", function() RR_LOOT_FRAME:Hide() end)

local ev = CreateFrame("Frame")
ev:RegisterEvent("LOOT_OPENED")
ev:SetScript("OnEvent", function(self, event) if event=="LOOT_OPENED" then C_Timer.After(0.3, ScanLoot) end end)

SLASH_RAIDGLOTER1 = "/rr" SLASH_RAIDGLOTER2 = "/raidgloter" SLASH_RAIDGLOTER3 = "/ggloter"
SlashCmdList["RAIDGLOTER"] = function() if RR_LOOT_FRAME:IsShown() then RR_LOOT_FRAME:Hide() else RR_Loot_Display_Refresh() end end

print("|cFF00FF00RaidGGLoter v4.1 INF BANDA cargado - /rr - Botones RAID/BANDA listos|r")
