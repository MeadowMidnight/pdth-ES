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
if not vanilla_bonuses then
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

function PlayerDamage:play_whizby(position)
	self._unit:sound():play_whizby({position = position})
	managers.rumble:play("bullet_whizby")
end
 
 
function PlayerDamage:damage_bullet(attack_data)
	local damage_info = {
		result = {type = "hurt", variant = "bullet"},
		attacker_unit = attack_data.attacker_unit
	}
	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end
 
		self:_call_listeners(damage_info)
		return
	elseif self._invulnerable then
		self:_call_listeners(damage_info)
		return
	elseif self:incapacitated() then
		return
	elseif PlayerDamage:_look_for_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)
		return
	end
 
	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end
 
	self._unit:sound():play("player_hit")
	
	self._unit:camera():play_shaker("player_bullet_damage", 0.5)	
	
	managers.rumble:play("damage_bullet")
	self:_hit_direction(attack_data.col_ray)
	if self._bleed_out then
		self:_bleed_out_damage(attack_data)
		return
	end
 
	local health_subtracted = self:_calc_armor_damage(attack_data)
	
	health_subtracted = health_subtracted or self:_calc_health_damage(attack_data)	
	self._next_allowed_dmg_t = TimerManager:game():time() + self._dmg_interval
	self._last_received_dmg = health_subtracted
	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out then
		managers.challenges:set_flag("bullet_to_bleed_out")
	end
 
	self:_call_listeners(damage_info)
end
