local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local init_original = M79GrenadeBase.init
function M79GrenadeBase:init(unit)
	init_original(self, unit)
	self._collision_slotmask = self._collision_slotmask - World:make_slot_mask(16)
end