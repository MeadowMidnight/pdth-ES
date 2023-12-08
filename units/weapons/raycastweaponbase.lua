local init_original = RaycastWeaponBase.init
local setup_original = RaycastWeaponBase.setup
local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
local vanilla_bonuses = D:conf("vanilla_bonuses") or false
local reload_multi = 1.2
local sharp_multi = 0.75
local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")
local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
if not vanilla_bonuses then
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
module:hook(RaycastWeaponBase, "_fire_sound", function(self)
    self:play_tweak_data_sound("fire")
    self:play_tweak_data_sound("stop_fire")
end)
module:hook(RaycastWeaponBase, "stop_shooting", function(self)
	self._shooting = nil
end)
module:hook(RaycastWeaponBase, "start_shooting", function(self,...)
	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
end)
module:pre_hook(RaycastWeaponBase, "fire", function(self)
    self:_fire_sound()
end)

--[[local EnemyFalloffs = {
    m4_npc            = 5000,
    m14_npc           = 10000,
    c45_npc           = 2250,
    beretta92_npc     = 3000,
    raging_bull_npc   = 2700,
    r870_npc          = 1500,
    mossberg_npc      = 1200,
    mp5_npc           = 4500,
    mac11_npc         = 3750,
    hk21_npc          = 4000,
    shield_pistol_npc = 2250,
    sniper_rifle_npc  = 60000,
    m79_npc           = 0x7FFFFFFF,   -- grenades don't miss
    glock_18_npc      = 1500,
    ak47_npc          = 4000,
    sentry_gun_npc    = 3000
}
 
function RaycastWeaponBase:damage_player(col_ray, from_pos, direction)
    local unit = managers.player:player_unit()
    if not unit then
        return
    end
 
    local ray_data = {}
    ray_data.ray = direction
    ray_data.normal = -direction
    local head_pos = unit:movement():m_head_pos()
    local head_dir = Vector3()  -- this was a temporary global variable, I have no idea why
    local head_dis = mvector3.direction(head_dir, from_pos, head_pos)
    local shoot_dir = Vector3() -- this one too
    mvector3.set(shoot_dir, col_ray and col_ray.ray or direction)
    local cos_f = mvector3.dot(shoot_dir, head_dir)
    if cos_f <= 0.1 then
        return
    end
 
    local hitFalloff = 0x7FFFFFFF
    local missMult   = 0
    local hitChance
 
    if EnemyFalloffs[self._name_id] ~= nil then
        hitFalloff = EnemyFalloffs[self._name_id]
    end
 
    if head_dis > 0 then
        missMult = head_dis / hitFalloff
    end
 
    if missMult > 4 then
        hitChance = 0
    else
        hitChance = 1 / math.pow(2, missMult)
    end
 
    local b = head_dis / cos_f
    if not col_ray or b < col_ray.distance then
        mvector3.set_length(shoot_dir, b)
        mvector3.multiply(head_dir, head_dis)
        mvector3.subtract(shoot_dir, head_dir)
        local proj_len = mvector3.length(shoot_dir)
        ray_data.position = head_pos + shoot_dir
        if proj_len < 30 then
            if World:raycast("ray", from_pos, head_pos, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report") then
                return nil, ray_data
            else
                local hitDie = math.random()
 
                if hitDie > hitChance then
                    unit:character_damage():play_whizby(ray_data.position)
                    return nil, ray_data
                end
 
                return true, ray_data
            end
 
        elseif proj_len < 100 and b > 500 then
            unit:character_damage():play_whizby(ray_data.position)
        end
 
    end
 
    return nil, ray_data
end ]]