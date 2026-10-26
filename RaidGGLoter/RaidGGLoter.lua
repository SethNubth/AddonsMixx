RaidRoll_DB = RaidRoll_DB or { ["Loot"] = { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 } }
RaidRoll_DB["Loot"] = RaidRoll_DB["Loot"] or { ["TOTAL WINDOWS"]=0, ["CURRENT WINDOW"]=0 }

local seen, LastMsgTime, LastLootTime = {}, 0, 0
local function GetID(link) if not link then return 0 end return tonumber(link:match("item:(%d+)")) or 0 end
local function IsDupe(id, mob)
    local k = mob.."_"..id
    if seen[k] and GetTime()-seen[k] < 15 then return true end
    seen[k]=GetTime() return false
end

-- FRAME
RR_LOOT_FRAME = CreateFrame("Frame", "RR_LOOT_FRAME", UIParent)
RR_LOOT_FRAME:SetSize(430, 300)
RR_LOOT_FRAME:SetPoint("CENTER",0,50)
RR_LOOT_FRAME:SetBackdrop({bgFile="Interface\\DialogBox\\UI-DialogBox-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=32, edgeSize=16, insets={left=4,right=4,top=4,bottom=4}})
RR_LOOT_FRAME:SetMovable(true) RR_LOOT_FRAME:EnableMouse(true) RR_LOOT_FRAME:RegisterForDrag("LeftButton")
RR_LOOT_FRAME:SetScript("OnDragStart", function(s) s:StartMoving() end)
RR_LOOT_FRAME:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)
RR_LOOT_FRAME:Hide()

local title = RR_LOOT_FRAME:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOP",0,-10) title:SetText("|cFFFFD700RaidGGLoter v1.1|r")

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
    if now > LastMsgTime+30 then
        db["TOTAL WINDOWS"]=db["TOTAL WINDOWS"]+1 db["CURRENT WINDOW"]=db["TOTAL WINDOWS"]
        db[db["TOTAL WINDOWS"]] = {["MOB NAME"]=mob, ["TOTAL ITEMS"]=0} LastMsgTime=now
        return db[db["TOTAL WINDOWS"]]
    else return db[db["TOTAL WINDOWS"]] end
end

local function ScanLoot()
    if GetNumLootItems()==0 then return end
    local mob = UnitName("target") or "Boss"
    local cur = AddWindow(mob)
    for slot=1,Get
