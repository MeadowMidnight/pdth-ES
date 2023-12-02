local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
--[[local multi_spawns = D:conf("multi_spawns") or false
local GroupHook = module:hook_class("GroupAIStateBesiege")
if not multi_spawns then
	return
end ]]
module:post_hook(GroupHook, "_init_misc_data", function(self)
	self._police_force_max = 100
end, false)
