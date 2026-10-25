RR_EPGPHasLoaded=true

-- CACHE GLOBAL
local EPGP_CACHE = {}
local EPGP_CACHE_EXPIRE = 10 -- segundos
local GUILD_ROSTER_HASH = {}
local LAST_ROSTER_UPDATE = 0
local LAST_GUILDINFO_PARSE = 0

local lower = string.lower
local tonum = tonumber
local strtrim_l = strtrim
local GetTime_l = GetTime

-- Crea hash table de la guild UNA sola vez
local function BuildRosterHash()
    local now = GetTime_l()
    if now - LAST_ROSTER_UPDATE < 5 and next(GUILD_ROSTER_HASH) then return end -- no rebuild cada 5s
    
    wipe(GUILD_ROSTER_HASH)
    if not IsInGuild() then return end
    
    local name, officernote, EP, GP
    for i=1, GetNumGuildMembers(true) do
        name, _, _, _, _, _, _, officernote = GetGuildRosterInfo(i)
        if name then
            local nl = lower(name)
            officernote = strtrim_l(officernote or "")
            EP, GP = strsplit(",", officernote)
            EP = tonum(EP)
            GP = tonum(GP)
            -- Si es main guarda directo
            if EP and GP then
                GUILD_ROSTER_HASH[nl] = {ep=EP, gp=GP, main=nil}
            else
                -- Si es ALT guarda referencia al main
                GUILD_ROSTER_HASH[nl] = {ep=nil, gp=nil, main=lower(officernote)}
            end
        end
    end
    LAST_ROSTER_UPDATE = now
end

function RR_ReallyGetEPGPGuildData()
    if not IsInGuild() then return end
    local now = GetTime_l()
    if now - LAST_GUILDINFO_PARSE < 10 then return end
    LAST_GUILDINFO_PARSE = now
    
    local info = GetGuildInfoText()
    if not info then return end
    -- Extrae todo entre -EPGP- -EPGP- con pattern único
    local block = info:match("%-EPGP%-(.-)%-EPGP%-")
    if not block then return end
    for k,v in block:gmatch("@([A-Z_]+):(%d+)") do
        RaidRoll_DB[k] = tonum(v)
    end
end

function RR_ReallyGetEPGPCharacterData(character)
    if not character or not IsInGuild() then return 0, false, 0, 0 end
    
    RR_ReallyGetEPGPGuildData()
    BuildRosterHash()
    
    local charL = lower(character)
    local now = GetTime_l()
    
    -- 1. Cache de 10s para doble click instantáneo
    local cached = EPGP_CACHE[charL]
    if cached and now - cached.t < EPGP_CACHE_EXPIRE then
        return cached.PR, cached.Above, cached.EP, cached.GP
    end

    local data = GUILD_ROSTER_HASH[charL]
    local EP, GP = 0, 0
    
    if data then
        if data.ep then
            EP = data.ep
            GP = data.gp
        elseif data.main and RaidRoll_DBPC[UnitName("player")]["RR_RollCheckBox_Enable_Alt_Mode"] then
            -- Es ALT, busca main en hash O(1) no loop
            local mainData = GUILD_ROSTER_HASH[data.main]
            if mainData and mainData.ep then
                EP = mainData.ep
                GP = mainData.gp
            end
        end
    end

    local BASE_GP = RaidRoll_DB["BASE_GP"] or 100
    local MIN_EP = RaidRoll_DB["MIN_EP"] or 0
    GP = GP + BASE_GP
    
    local PR = 0
    if GP > 0 then PR = ceil(EP / GP * 100) / 100 end
    local Above = EP >= MIN_EP

    -- Guarda en cache
    EPGP_CACHE[charL] = {PR=PR, Above=Above, EP=EP, GP=GP, t=now}
    
    return PR, Above, EP, GP
end

-- Llamar esto cuando cambias de zona o con /reload para refrescar
function RR_FlushEPGPCache()
    wipe(EPGP_CACHE)
    wipe(GUILD_ROSTER_HASH)
    LAST_ROSTER_UPDATE = 0
end

-- Auto flush cada 60s
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elapsed)
    self.t = (self.t or 0) + elapsed
    if self.t > 60 then
        RR_FlushEPGPCache()
        self.t = 0
    end
end)
