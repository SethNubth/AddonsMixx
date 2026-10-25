-- Create the frame for the options panel
function Setup_RR_Panel()
 RaidRoll_Panel = {};
 RaidRoll_Panel.panel = CreateFrame( "Frame", "Raid Roll Panel", UIParent );
 RaidRoll_Panel.panel.name = "Raid Roll";
 InterfaceOptions_AddCategory(RaidRoll_Panel.panel);
 
  -- FIX 1: Nombre único, antes tenías 2 frames con "Raid Roll Loot Panel"
  RaidRoll_PriorityPanel = {};
  RaidRoll_PriorityPanel = CreateFrame( "Frame", "Raid Roll Priority Panel", UIParent );
  RaidRoll_PriorityPanel.name = "Priority";
  RaidRoll_PriorityPanel.parent = "Raid Roll"
  InterfaceOptions_AddCategory(RaidRoll_PriorityPanel);
 
 if RaidRoll_LootTrackerLoaded==true then
	  RaidRoll_LootPanel = {};
	  RaidRoll_LootPanel = CreateFrame( "Frame", "Raid Roll Loot Window Panel", UIParent );
	  RaidRoll_LootPanel.name = "Loot Window";
	  RaidRoll_LootPanel.parent = "Raid Roll"
	  InterfaceOptions_AddCategory(RaidRoll_LootPanel);
 end
 
 local x,y = 30,-120
 
 -- FIX 2: Check nil seguro
 if RaidRoll_Panel.panel then
	 RaidRoll_Panel.panel:SetScript("OnShow", function()
		RR_GuildRankUpdate()
		RR_GetEPGPGuildData()
		if RaidRoll_LootTrackerLoaded==true then
			if Raid_Roll_SetMsg3_EditBox then Raid_Roll_SetMsg3_EditBox:SetCursorPosition(0) end
			if Raid_Roll_SetMsg2_EditBox then Raid_Roll_SetMsg2_EditBox:SetCursorPosition(0) end
			if Raid_Roll_SetMsg1_EditBox then Raid_Roll_SetMsg1_EditBox:SetCursorPosition(0) end
		end
	end)
 end

-- Options menu
	Raid_Roll_PanelName_String =  RaidRoll_Panel.panel:CreateFontString("Raid_Roll_PanelName_String" ,"ARTWORK","GameFontNormal");
	Raid_Roll_PanelName_String:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -10)
	Raid_Roll_PanelName_String:SetJustifyH("LEFT")
	Raid_Roll_PanelName_String:SetText("|cFFC41F3B" .. RAIDROLL_LOCALE["OPTIONSTITLE"])
	if (GetLocale() ~= "zhTW") then
		Raid_Roll_PanelName_String:SetFont("Fonts\\FRIZQT__.TTF", 16)
	end
	if (GetLocale() == "zhCN") then
		Raid_Roll_PanelName_String:SetFont("Fonts\\ZYKai_T.TTF", 20)
	end
	
-- General_Settings
	Raid_Roll_PanelName_String2 =  RaidRoll_Panel.panel:CreateFontString(nil ,"ARTWORK","GameFontNormal");
	Raid_Roll_PanelName_String2:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -40)
	Raid_Roll_PanelName_String2:SetJustifyH("LEFT")
	Raid_Roll_PanelName_String2:SetText("|cFF2459FF" .. RAIDROLL_LOCALE["General_Settings"])
	if (GetLocale() ~= "zhTW") then
		Raid_Roll_PanelName_String2:SetFont("Fonts\\FRIZQT__.TTF", 16)
	end
	if (GetLocale() == "zhCN") then
		Raid_Roll_PanelName_String2:SetFont("Fonts\\ZYKai_T.TTF", 15)
	end
 
-- [ ] Catch Unannounced Rolls
  	RR_RollCheckBox_Unannounced_panel = CreateFrame("CheckButton", "RR_RollCheckBox_Unannounced_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_Unannounced_panel:SetWidth(20)
	RR_RollCheckBox_Unannounced_panel:SetHeight(20)
	RR_RollCheckBox_Unannounced_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -60)
	_G["RR_RollCheckBox_Unannounced_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Catch_Unannounced_Rolls"])
	if (GetLocale() ~= "zhTW")  then
		_G["RR_RollCheckBox_Unannounced_panel".."Text"]:SetFont("Fonts\\FRIZQT__.TTF", 12)
	end
	RR_RollCheckBox_Unannounced_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_Unannounced_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_Unannounced_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- [ ] Allow all rolls (e.g. 1-50)
	RR_RollCheckBox_AllRolls_panel = CreateFrame("CheckButton", "RR_RollCheckBox_AllRolls_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_AllRolls_panel:SetWidth(20)
	RR_RollCheckBox_AllRolls_panel:SetHeight(20)
	RR_RollCheckBox_AllRolls_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -80)
	_G["RR_RollCheckBox_AllRolls_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Allow_all_rolls"])
	RR_RollCheckBox_AllRolls_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
 	RR_RollCheckBox_AllRolls_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_AllRolls_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Allow Extra Rolls
 	RR_RollCheckBox_ExtraRolls_panel = CreateFrame("CheckButton", "RaidRollCheckBox_ExtraRolls_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_ExtraRolls_panel:SetWidth(20)
	RR_RollCheckBox_ExtraRolls_panel:SetHeight(20)
	RR_RollCheckBox_ExtraRolls_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -100)
	_G["RaidRollCheckBox_ExtraRolls_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Allow_Extra_Rolls"])
	RR_RollCheckBox_ExtraRolls_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_ExtraRolls_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_ExtraRolls_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Announce winner to guild
	RR_RollCheckBox_GuildAnnounce = CreateFrame("CheckButton", "RR_RollCheckBox_GuildAnnounce", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_GuildAnnounce:SetWidth(20)
	RR_RollCheckBox_GuildAnnounce:SetHeight(20)
	RR_RollCheckBox_GuildAnnounce:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -120)
	_G["RR_RollCheckBox_GuildAnnounce".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Announce_winner_to_guild"])
	RR_RollCheckBox_GuildAnnounce:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_GuildAnnounce:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_GuildAnnounce:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Use officer channel
	RR_RollCheckBox_GuildAnnounce_Officer = CreateFrame("CheckButton", "RR_RollCheckBox_GuildAnnounce_Officer", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_GuildAnnounce_Officer:SetWidth(15)
	RR_RollCheckBox_GuildAnnounce_Officer:SetHeight(15)
	RR_RollCheckBox_GuildAnnounce_Officer:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  40, -135)
	_G["RR_RollCheckBox_GuildAnnounce_Officer".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Use_officer_channel"])
	RR_RollCheckBox_GuildAnnounce_Officer:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_GuildAnnounce_Officer:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_GuildAnnounce_Officer:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Auto Announce Countdown
 	RR_RollCheckBox_Auto_Announce = CreateFrame("CheckButton", "RR_RollCheckBox_Auto_Announce", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_Auto_Announce:SetWidth(20)
	RR_RollCheckBox_Auto_Announce:SetHeight(20)
	RR_RollCheckBox_Auto_Announce:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  240, -60)
	_G["RR_RollCheckBox_Auto_Announce".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Auto_Announce_Count"])
	RR_RollCheckBox_Auto_Announce:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_Auto_Announce:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_Auto_Announce:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Auto Close Window
 	RR_RollCheckBox_Auto_Close = CreateFrame("CheckButton", "RR_RollCheckBox_Auto_Close", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_Auto_Close:SetWidth(20)
	RR_RollCheckBox_Auto_Close:SetHeight(20)
	RR_RollCheckBox_Auto_Close:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  240, -80)
	_G["RR_RollCheckBox_Auto_Close".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Auto_Close_Window"])
	RR_RollCheckBox_Auto_Close:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_Auto_Close:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_Auto_Close:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] No countdown
 	RR_RollCheckBox_No_countdown = CreateFrame("CheckButton", "RR_RollCheckBox_No_countdown", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_No_countdown:SetWidth(20)
	RR_RollCheckBox_No_countdown:SetHeight(20)
	RR_RollCheckBox_No_countdown:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  240, -100)
	_G["RR_RollCheckBox_No_countdown".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["No_countdown"])
	RR_RollCheckBox_No_countdown:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_No_countdown:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_No_countdown:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- [ ] Multi Rollers
 	RR_RollCheckBox_Multi_Rollers = CreateFrame("CheckButton", "RR_RollCheckBox_Multi_Rollers", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_Multi_Rollers:SetWidth(20)
	RR_RollCheckBox_Multi_Rollers:SetHeight(20)
	RR_RollCheckBox_Multi_Rollers:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  240, -120)
	_G["RR_RollCheckBox_Multi_Rollers".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Multi_Rollers"])
	RR_RollCheckBox_Multi_Rollers:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_Multi_Rollers:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_Multi_Rollers:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Display Settings
	Raid_Roll_Display_Settings =  RaidRoll_Panel.panel:CreateFontString(nil ,"ARTWORK","GameFontNormal");
	Raid_Roll_Display_Settings:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -160)
	Raid_Roll_Display_Settings:SetJustifyH("LEFT")
	Raid_Roll_Display_Settings:SetText("|cFF2459FF" .. RAIDROLL_LOCALE["Raid_Roll_Display_Settings"])
	Raid_Roll_Display_Settings:SetFont("Fonts\\FRIZQT__.TTF", 16)
	
-- [ ] Show Rank Beside Name
	RR_RollCheckBox_ShowRanks_panel = CreateFrame("CheckButton", "RaidRollCheckBox_ShowRanks_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_ShowRanks_panel:SetWidth(20)
	RR_RollCheckBox_ShowRanks_panel:SetHeight(20)
	RR_RollCheckBox_ShowRanks_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -180)
	_G["RaidRollCheckBox_ShowRanks_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Show_Rank_Beside_Name"])
	RR_RollCheckBox_ShowRanks_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_ShowRanks_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_ShowRanks_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Show Group Number Beside Name
	RR_RollCheckBox_ShowGroupNumber_panel = CreateFrame("CheckButton", "RR_RollCheckBox_ShowGroupNumber_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_ShowGroupNumber_panel:SetWidth(20)
	RR_RollCheckBox_ShowGroupNumber_panel:SetHeight(20)
	RR_RollCheckBox_ShowGroupNumber_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -200)
	_G["RR_RollCheckBox_ShowGroupNumber_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Show_Group_Beside_Name"])
	RR_RollCheckBox_ShowGroupNumber_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_ShowGroupNumber_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_ShowGroupNumber_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
-- [ ] Show Class Colors
	RR_RollCheckBox_ShowClassColors_panel = CreateFrame("CheckButton", "RR_RollCheckBox_ShowClassColors_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_ShowClassColors_panel:SetWidth(20)
	RR_RollCheckBox_ShowClassColors_panel:SetHeight(20)
	RR_RollCheckBox_ShowClassColors_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  240, -180)
	_G["RR_RollCheckBox_ShowClassColors_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Show_Class_Colors"])
	RR_RollCheckBox_ShowClassColors_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_ShowClassColors_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_ShowClassColors_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- EPGP Settings
	Raid_Roll_EPGP_Settings =  RaidRoll_Panel.panel:CreateFontString(nil ,"ARTWORK","GameFontNormal");
	Raid_Roll_EPGP_Settings:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 20, -230)
	Raid_Roll_EPGP_Settings:SetJustifyH("LEFT")
	Raid_Roll_EPGP_Settings:SetText("|cFF2459FF" .. RAIDROLL_LOCALE["Raid_Roll_EPGP_Settings"])
	Raid_Roll_EPGP_Settings:SetFont("Fonts\\FRIZQT__.TTF", 16)
	
-- [ ] Enable EPGP mode
	RR_RollCheckBox_EPGPMode_panel = CreateFrame("CheckButton", "RR_RollCheckBox_EPGPMode_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_EPGPMode_panel:SetWidth(20)
	RR_RollCheckBox_EPGPMode_panel:SetHeight(20)
	RR_RollCheckBox_EPGPMode_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  30, -250)
	_G["RR_RollCheckBox_EPGPMode_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Enable_EPGP_mode"])
	RR_RollCheckBox_EPGPMode_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_EPGPMode_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_EPGPMode_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- [ ] Enable threshold levels
	RR_RollCheckBox_EPGPThreshold_panel = CreateFrame("CheckButton", "RR_RollCheckBox_EPGPThreshold_panel", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_EPGPThreshold_panel:SetWidth(15)
	RR_RollCheckBox_EPGPThreshold_panel:SetHeight(15)
	RR_RollCheckBox_EPGPThreshold_panel:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  40, -265)
	_G["RR_RollCheckBox_EPGPThreshold_panel".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Enable_threshold_levels"])
	RR_RollCheckBox_EPGPThreshold_panel:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_EPGPThreshold_panel:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_EPGPThreshold_panel:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- [ ] Enable Alt Mode
	RR_RollCheckBox_Enable_Alt_Mode = CreateFrame("CheckButton", "RR_RollCheckBox_Enable_Alt_Mode", RaidRoll_Panel.panel, "UICheckButtonTemplate")
	RR_RollCheckBox_Enable_Alt_Mode:SetWidth(15)
	RR_RollCheckBox_Enable_Alt_Mode:SetHeight(15)
	RR_RollCheckBox_Enable_Alt_Mode:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft",  40, -280)
	_G["RR_RollCheckBox_Enable_Alt_Mode".."Text"]:SetText("|cFFFFFFFF" .. RAIDROLL_LOCALE["Enable_Alt_Mode"])
	RR_RollCheckBox_Enable_Alt_Mode:SetScript("OnClick",RaidRoll_CheckButton_Update_Panel)
	RR_RollCheckBox_Enable_Alt_Mode:SetScript("OnEnter",function(self) RR_MouseOverTooltip(self:GetName()) end)
	RR_RollCheckBox_Enable_Alt_Mode:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- MiscSettings
	Raid_Roll_Misc_Settings =  RaidRoll_Panel.panel:CreateFontString(nil ,"ARTWORK","GameFontNormal");
	Raid_Roll_Misc_Settings:SetPoint("TopLeft", RaidRoll_Panel.panel, "TopLeft", 240, -230)
	Raid_Roll_Misc_Settings:SetJustifyH("LEFT")
	Raid_Roll_Misc_Settings:SetText("|cFF2459FF" .. RAIDROLL_LOCALE["Raid_Roll_Misc_Settings"])
	Raid_Roll_Misc_Settings:SetFont("Fonts\\FRIZQT__.TTF", 16)
end
