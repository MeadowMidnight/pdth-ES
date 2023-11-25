function MenuManager:toggle_chatinput()
	if Application:editor() then
		return
	end

	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	if self:active_menu() then
		return
	end
	
	if managers.hud then
		managers.hud:toggle_chatinput()
	end

end
module:hook("OnMenuSetup", "OnMenuSetup_HideMenuItems", "menu_main", function(self, menu, nodes)
	self:update_menu_item(nodes, "main", "play_campaign", { visible_callback = "hide_unless_option_set" })
end)