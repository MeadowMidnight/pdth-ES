local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function TeamAIDamage:inc_dodge_count(n)
	return
end
local TeamAIDamage = module:hook_class("TeamAIDamage")
module:post_hook(55, TeamAIDamage, "_regenerated", function(self)
	managers.hud:set_mugshot_health(self._unit:unit_data().mugshot_id, self._health_ratio)
end, false)

module:hook(55, TeamAIDamage, "_apply_damage", function(self, attack_data, result)
	local damage_percent, health_subtracted =
		module:call_orig(TeamAIDamage, "_apply_damage", self, attack_data, result)
	if health_subtracted > 0 then
		managers.hud:set_mugshot_health(self._unit:unit_data().mugshot_id, self._health_ratio)
		if self._unit:network() then
			local hp = math.round(self._health_ratio * 100)
			self._unit:network():send("set_health", math.clamp(hp, 0, 100))
		end
	end
	return damage_percent, health_subtracted
end, true)
