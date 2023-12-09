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
MaskOptionInitiator = MaskOptionInitiator or class()
function MaskOptionInitiator:modify_node(node)
	local choose_mask = node:item("choose_mask")
	local params = {
		name = "choose_mask",
		text_id = "menu_choose_mask",
		callback = "choice_mask"
	}
	if choose_mask:parameters().help_id then
		params.help_id = choose_mask:parameters().help_id
	end
	local data_node = {
		type = "MenuItemMultiChoice"
	}
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_clowns",
		value = "clowns"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_developer",
		value = "developer"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_hockey_com",
		value = "hockey_com"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_alienware",
		value = "alienware"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_bf3",
		value = "bf3"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_santa",
		value = "santa"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_president",
		value = "president"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_gold",
		value = "gold"
	})
	if SystemInfo:platform() == Idstring("WIN32") and (Steam:is_product_owned(500) or Steam:is_product_owned(550)) then
		table.insert(data_node, {
			_meta = "option",
			text_id = "menu_mask_zombie",
			value = "zombie"
		})
	end
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_troll",
		value = "troll"
	})
	if SystemInfo:platform() == Idstring("WIN32") and Steam:is_product_owned(207816) then
		table.insert(data_node, {
			_meta = "option",
			text_id = "menu_mask_music",
			value = "music"
		})
	end
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_vyse",
		value = "vyse"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_halloween",
		value = "halloween"
	})
	table.insert(data_node, {
		_meta = "option",
		text_id = "menu_mask_tester",
		value = "tester"
	})
	if SystemInfo:platform() == Idstring("WIN32") then
		table.insert(data_node, {
			_meta = "option",
			text_id = "menu_mask_end_of_the_world",
			value = "end_of_the_world"
		})
	end
	choose_mask:init(data_node, params)
	choose_mask:set_callback_handler(MenuCallbackHandler:new())
	choose_mask:set_value(managers.user:get_setting("mask_set"))
	return node
end