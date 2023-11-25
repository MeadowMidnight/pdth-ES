local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local colors = {
	hp_low = Color(1, 0, 0),
	hp_normal = Color(0.5, 0.8, 0.4),
	state_downed = Color(1, 0, 0),
}

local HUDManager = module:hook_class("HUDManager")
module:post_hook(HUDManager, "_add_mugshot", function(self, data, mugshot_data)
	if Network:is_server() then
		mugshot_data.health_background:show()
		mugshot_data.health_health:show()
	end
end, false)

module:post_hook(HUDManager, "layout_mugshot_health", function(self, data, amount)
	if not data.peer_id and data.state_name == "mugshot_downed" then
		data.health_health:set_color(colors.state_downed)
	end
end, false)

module:post_hook(HUDManager, "set_mugshot_normal", function(self, id)
	local data = self:_get_mugshot_data(id)
	if not data or data.peer_id or not data.health_amount then
		return
	end

	local color = data.health_amount < 0.33 and colors.hp_low or colors.hp_normal
	data.health_health:set_color(color)
end, false)