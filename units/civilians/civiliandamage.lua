local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local CivilianDamage = module:hook_class("CivilianDamage")
module:post_hook(CivilianDamage, "die", function(self, variant)
	self._unit:base():set_slot(self._unit, 16)
end, false)

