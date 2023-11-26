local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
local vanilla_bonuses = D:conf("vanilla_bonuses") or false
local protector_multi = 1.5
if not is_singleplayer then
	return
end
if vanilla_bonuses then
    local protector_multi = 1.1
end
function PlayerDamage:_max_armor()
	if crew_bonus == "protector" or crew_bonus2 == "protector" or crew_bonus3 == "protector" then
		return (self._ARMOR_INIT + managers.player:body_armor_value()) * protector_multi
	else
		return (self._ARMOR_INIT + managers.player:body_armor_value()) * managers.player:synced_crew_bonus_upgrade_value("protector", 1)
	end
end
function PlayerDamage:_regenerated()
	self._health = self:_max_health()
	self._revive_health_i = 1
	if crew_bonus == "more_blood_to_bleed" or crew_bonus2 == "more_blood_to_bleed" or crew_bonus3 == "more_blood_to_bleed" then
		self._down_time = tweak_data.player.damage.DOWNED_TIME + 5
	else
		self._down_time = tweak_data.player.damage.DOWNED_TIME + managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 0)
	end
	self._regenerate_timer = nil
	self:_send_set_health()
	self:_set_health_effect()
	self._said_hurt = false
end
