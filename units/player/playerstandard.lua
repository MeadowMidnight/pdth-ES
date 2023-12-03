local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local _check_action_primary_attack = PlayerStandard._check_action_primary_attack
local _StockholmSyndrome = {
	_delay = 0.2
}
function PlayerStandard:_check_action_primary_attack(t, input)
	local _res = _check_action_primary_attack(self, t, input)
	if self._shooting and t > _StockholmSyndrome._delay and Global.level_data.level_id ~= "secret_stash" then
		_StockholmSyndrome._delay = t
		local _local_pos = self._unit:position()
		for u_key, u_data in pairs(managers.enemy:all_civilians()) do
			if mvector3.distance(u_data.unit:position(), _local_pos) <= 50000000000 then
				u_data.unit:brain():on_intimidated(1, self._unit)
			end			
		end		
	end
	return _res
end


