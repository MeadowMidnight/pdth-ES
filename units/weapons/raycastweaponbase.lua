local init_original = RaycastWeaponBase.init
local setup_original = RaycastWeaponBase.setup
local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
local vanilla_bonuses = D:conf("vanilla_bonuses") or false
local reload_multi = 1.2
local sharp_multi = 0.75
local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
if vanilla_bonuses then
    local reload_multi = 1.1
    local sharp_multi = 0.9
end
function RaycastWeaponBase:init(...)
	init_original(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
end

function RaycastWeaponBase:setup(...)
	setup_original(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
end

function RaycastWeaponBase:reload_speed_multiplier()
	if crew_bonus == "speed_reloaders" or crew_bonus2 == "speed_reloaders" or crew_bonus3 == "speed_reloaders" then
		local multiplier = managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
		multiplier = multiplier * reload_multi
		return multiplier
	else
		local multiplier = managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
		return multiplier
	end
end

function RaycastWeaponBase:damage_multiplier()
	local multiplier = managers.player:upgrade_value(self._name_id, "damage_multiplier", 1)
	if crew_bonus == "aggressor" or crew_bonus2 == "aggressor" or crew_bonus3 == "aggressor" then
		multiplier = multiplier * 1.1
		return multiplier
	else
		return multiplier
	end
end

function RaycastWeaponBase:spread_multiplier()
	local multiplier = managers.player:upgrade_value(self._name_id, "spread_multiplier", 1)
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 1)
	if crew_bonus == "sharpshooters" or crew_bonus2 == "sharpshooters" or crew_bonus3 == "sharpshooters" then
		 multiplier = multiplier * sharp_multi
		 return multiplier
	else
		 return multiplier
	end
	return multiplier
end

function RaycastWeaponBase:replenish()
	local ammo_max_multiplier = managers.player:equipped_upgrade_value("extra_start_out_ammo", "player", "extra_ammo_multiplier")
	if crew_bonus == "big_game_hunters" or crew_bonus2 == "big_game_hunters" or crew_bonus3 == "big_game_hunters" then
		ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * 1.15
	else
		ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * managers.player:synced_crew_bonus_upgrade_value("more_ammo", 1, true)
	end
	self._ammo_max_per_clip = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")
	self._ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") * self._ammo_max_per_clip) * ammo_max_multiplier)
	self._ammo_total = self._ammo_max
	self._ammo_remaining_in_clip = self._ammo_max_per_clip
	self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
	self:update_damage()
end
