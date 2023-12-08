module:hook("OnMenuSetup", "OnMenuSetup_HideMenuItems", "menu_main", function(self, menu, nodes)
	self:update_menu_item(nodes, "main", "play_campaign", { visible_callback = "hide_unless_option_set" })
end)
module:hook(MenuManager, "refresh_level_select", function(node, verify_dlc_owned)
	if verify_dlc_owned and tweak_data.levels[Global.game_settings.level_id].dlc then
		local dlcs = string.split(managers.dlc:dlcs_string(), " ")
		if not table.contains(dlcs, tweak_data.levels[Global.game_settings.level_id].dlc) then
			Global.game_settings.level_id = "bank"
		end
	end

	for _, item in ipairs(node:items()) do
		local level_id = item:parameter("level_id")
		if level_id then
			item:set_value(level_id == Global.game_settings.level_id and "on" or "off")
		end
	end

	local item_difficulty = node:item("lobby_difficulty")
	if item_difficulty then
		item_difficulty:set_value(Global.game_settings.difficulty)
	end
end)
local MaskOptionInitiator = module:hook_class("MaskOptionInitiator")
module:post_hook(MaskOptionInitiator, "add_additional_items", function(self, data_node)
	local weight = 1.11
	for mask_key, mask_id in pairs({
		developer = "developer",
		hockey_com = "hockey_com",
		troll = "troll",
		tester_group = "tester",
		vyse = "vyse",
	}) do
		if not managers.network.account:has_mask(mask_key) then -- prevent dupes
			table.insert(data_node, {
				text_id = "menu_mask_" .. mask_id,
				value = "fake_" .. mask_id,
				weight = weight,
			})
			weight = weight + 0.01
		end
	end
end, true)
end
