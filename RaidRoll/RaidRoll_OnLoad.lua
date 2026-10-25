RaidRollHasLoaded = true
-- FIX BUG 1: Inicializar para que no crashee al entrar a raid
if RR_LastItemDataReSent == nil then RR_LastItemDataReSent = time() - 60 end

function RR_LootSettings_Setup()
--[[ 
	_G["LootButton2"]:SetScript("OnMouseDown",	function()
		RR_Test("pressed")
	end)
]]
end

RR_ListOfIcons={}
RR_NumberOfIcons = 5
RR_ListOfIcons = {"","! ","(N)","(G)","(NG)"}

function RR_LootWindowEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6 = ...;

	if event == "CHAT_MSG_ADDON" then
		if arg1 == "RRL" then
			if RaidRoll_DB["debug"] == true then 
				RR_Test("---Addon messages---")
				RR_Test(event)
				RR_Test(tostring(arg1))
				RR_Test(tostring(arg2))
				RR_Test(tostring(arg3))
				RR_Test(tostring(arg4))
				RR_Test(tostring(arg5))
				RR_Test(tostring(arg6))
			end
			
			if arg2 == "Request" then
				-- FIX BUG 2: Check nil antes de sumar
				if RR_LastItemDataReSent and time() >= RR_LastItemDataReSent + 5 then 
					RR_LastItemDataReSent = time()
					RR_SendRequestFrame:SetScript("OnUpdate", function() 
						if RR_LastItemDataReSent and time() >= RR_LastItemDataReSent + 5 then
							RR_SendItemInfo()
							RR_SendRequestFrame:SetScript("OnUpdate", function() end)
						end
					end)
				end
			else
				if RaidRoll_LootTrackerLoaded == true then
					RR_AddonMessageReceived(arg2,arg3)
				end
			end
		end
	end

	if event == "LOOT_OPENED" then
		if RaidRoll_DB["debug"] == true then 
			RR_Test(event)
			RR_Test(tostring(arg1))
			RR_Test(tostring(arg2))
		end
		RR_SendItemInfo()
	end
end

function RR_SendItemInfo()
local player_name,mob_name,mob_guid,numLootItems,
	LootNumber,WeHaveFoundAnItem,ItemLink,AcceptItem,
	DontAcceptItem,AcceptableZone,ZoneName,Seperator,
	Version,String,ItemId, Type -- FIX BUG 3: Type era global y pisaba otras funciones

	player_name = UnitName("player"); 
	mob_name = UnitName("target"); 
	mob_guid = UnitGUID("target");
	
	if mob_guid == nil then mob_guid = "0xF1008F32001790BE" end
	
	if mob_guid ~= nil then
		local B = tonumber(mob_guid:sub(5,5), 16);
		local maskedB = B % 8;
		local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};
		if knownTypes[maskedB] ~= nil then 
			Type = knownTypes[maskedB]
		else
			Type = "unknown entity!"
		end
		if RaidRoll_DB["debug"] == true then RR_Test("Your target is a " .. tostring(Type)) end
		
		if Type ~= "NPC" then mob_name = "Unknown" end
		
		numLootItems = GetNumLootItems();
		LootNumber = 0
		
		if numLootItems ~= nil then
			if RaidRoll_DB["debug"] == true then RR_Test("The Mob Has Loots!") end
			if RaidRoll_DB["debug"] == true then RR_Test(numLootItems .. " items found") end
			
			WeHaveFoundAnItem = false
			
			for i=1,numLootItems do
				if LootSlotIsItem(i) then
					if WeHaveFoundAnItem == false then
						WeHaveFoundAnItem = true
					end
					
					LootNumber = LootNumber + 1
					
					local lootIcon, lootName, lootQuantity, rarity = GetLootSlotInfo(i);
					ItemLink = GetLootSlotLink(i); 
					
					if RR_Check_lootName == nil then RR_Check_lootName = {} end
					
					AcceptItem = false
					
					local _, _, _, _, ItemId = string.find(ItemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					ItemId = tonumber(ItemId)
					
					local _, _, _, ItemLvl = GetItemInfo(ItemId);
					ItemLvl = tonumber(ItemLvl);
					
					if ItemId == 46110 or ItemId == 47556 or ItemId == 45087 or ItemId == 49908 then
						AcceptItem = true
						if RaidRoll_DB["debug"] == true then RR_Test("[Rarity] This is an acceptable Item - " .. tostring(lootName)) end
					else
						if RaidRoll_DB["debug"] == true then RR_Test("[Rarity] This is >NOT< an acceptable Item - " .. tostring(lootName)) end
					end
					
					DontAcceptItem = false
					if ItemId == 34057 or ItemId == 36931 or ItemId == 36919 or ItemId == 36928 or ItemId == 36934 or ItemId == 36922 or ItemId == 36925 or ItemId == 47241 or ItemId == 49426 then
						DontAcceptItem = true
						if RaidRoll_DB["debug"] == true then RR_Test("[Epic Items] This is >NOT< an acceptable Item - " .. tostring(lootName)) end
					else
						if RaidRoll_DB["debug"] == true then RR_Test("[Epic Items] This is an acceptable Item - " .. tostring(lootName)) end
					end
					
					AcceptableZone = false
					ZoneName = GetRealZoneText();
					
					if ZoneName == "Trial of the Crusader" or ZoneName == "Icecrown Citadel" or ZoneName == "Naxxramas" or ZoneName == "Onyxia's Lair" or ZoneName == "The Eye of Eternity" or ZoneName == "The Obsidian Sanctum" or ZoneName == "Ulduar" or ZoneName == "Vault of Archavon" then
						AcceptableZone = true
						if RaidRoll_DB["debug"] == true then RR_Test("This is an acceptable Zone - " .. tostring(ZoneName)) end
					else
						if RaidRoll_DB["debug"] == true then RR_Test("This is >NOT< an acceptable zone - " .. tostring(ZoneName)) end
					end
					
					if RaidRoll_DBPC[UnitName("player")]["RR_Frame_WotLK_Dung_Only"] == false then
						local name, ins_type, _, _, maxPlayers = GetInstanceInfo()
						if RaidRoll_DB["debug"] == true then RR_Test("ins_type - " .. tostring(ins_type)) end
						if ins_type == "raid" or RaidRoll_DB["debug"] == true then
							AcceptableZone = true
							if RaidRoll_DB["debug"] == true then RR_Test("This is a Raid - " .. tostring(ZoneName)) end
						end
					end
					
					RR_Check_lootName[LootNumber] = lootName
					LootCount = 0
					RR_Temp_lootName = lootName
					
					if LootNumber > 1 then
						for i = 1,LootNumber-1 do
							if lootName == RR_Check_lootName[i] then
								LootCount = LootCount + 1
								lootName = RR_Temp_lootName .. LootCount
								RR_Check_lootName[LootNumber] = lootName
							end
						end
					end
					
					Seperator = "\a"
					Version = "Beta_2"
					String = ""
					
					String = (
						Version .. Seperator .. 
						player_name .. Seperator .. 
						mob_name .. Seperator .. 
						ItemId .. Seperator ..
						lootName .. Seperator ..
						ItemLvl
					) 
					
					if RR_LastItemDataReSent and time() >= RR_LastItemDataReSent + 60 then
						RR_LastItemDataReSent = time() - 10
						SendAddonMessage( "RRL", "Request" ,"RAID" );
					end
					
					if rarity > 3 or RaidRoll_DB["debug"] == true or AcceptItem == true then
						if AcceptableZone == true or RaidRoll_DB["debug"] == true then
							if DontAcceptItem == false or RaidRoll_DB["debug"] == true then
								if UnitInRaid("player") ~= nil then
									SendAddonMessage( "RRL", String ,"RAID" );
								end
								if IsInGuild() then
									SendAddonMessage( "RRL", String ,"GUILD" );
								end
							end
						end
					end
					
					if RaidRoll_DB["debug"] == true then 
						RR_Test(tostring(ItemLink))
						RR_Test(tostring(lootIcon))
						RR_Test(tostring(lootName))
						RR_Test(tostring(lootQuantity))
						RR_Test(tostring(rarity))	
					end
					
					if RaidRoll_LootTrackerLoaded == true then
						RR_Loot_Display_Refresh()	
					end
				end
			end
		end
	end
end

function RR_MouseOverTooltip(ID)
	if RR_Tooltips == nil then 
		RR_Tooltips = {}
	end
	
	RR_Tooltips[ID]=RAIDROLL_LOCALE[ID]
	
	if ID ~= nil then
		if string.find(ID, "Raid_Roll_SetSymbol") then
			CharID = tonumber(string.sub(ID,20))
			if RaidRoll_DB["debug"] == true then
				RR_Test(ID)
				RR_Test(CharID)
			end
			if RR_RollData ~= nil and RR_RollData[rr_CurrentRollID] ~= nil and RR_RollData[rr_CurrentRollID][CharID] ~= nil then
				RR_Tooltips[ID] = RollerName[rr_CurrentRollID][CharID] .. " " .. RollerRoll[rr_CurrentRollID][CharID] .. " " .. RR_RollData[rr_CurrentRollID][CharID]["LowHigh"]
				if RaidRoll_DBPC[UnitName("player")]["RR_EPGP_Enabled"] ==  true then
					RR_Tooltips[ID] = RollerName[rr_CurrentRollID][CharID] .. " " .. RR_RollData[rr_CurrentRollID][CharID]["EPGPValues"] .. " PR:" .. RR_EPGP_PRValue[rr_CurrentRollID][CharID]	
				end
			else
				RR_Tooltips[ID] = ""
			end
		end
	end
	
	GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
	GameTooltip:ClearAllPoints(); 
	GameTooltip:SetPoint("bottomleft", _G[ID], "top", 0, 0)
	GameTooltip:ClearLines()
	GameTooltip:SetText(RR_Tooltips[ID])
end

function RR_Test(msg)
	if type(msg) ~= "string" then
		msg = tostring(msg)
	end
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end
