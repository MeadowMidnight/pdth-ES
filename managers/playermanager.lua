local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local is_uc = Global.game_settings and Global.level_data.level_id == "secret_stash"
local module = ...
if not is_singleplayer then
	return
end
local PlayerManagerHook = module:hook_class("PlayerManager")
-- Post-hook to prevent game crash from mod conflicts --
module:post_hook(PlayerManagerHook, "_setup", function(self)
	if is_uc and Global.player_manager then
		Global.player_manager.default_kit.special_equipment_slots = {}
	end
end, false)