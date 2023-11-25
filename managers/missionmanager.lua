local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local MissionScript = module:hook_class("MissionScript")
module:post_hook(MissionScript, "init", function(self)
	local level = Global.level_data.level_id
	if level == "bank" then
	for _, id in pairs({ 104145, 104152, 104153, 104154 }) do
		local e = self:element(id)
		if not e then
			break
		end
		e:set_enabled(false)
		end
	end
end)