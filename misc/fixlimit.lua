local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local GroupHook = module:hook_class("GroupAIStateBesiege")
module:post_hook(GroupHook, "_init_misc_data", function(self)
	self._police_force_max = 35
end, false)
