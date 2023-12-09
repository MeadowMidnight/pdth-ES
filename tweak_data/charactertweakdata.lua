local CharacterTweakData = module:hook_class("CharacterTweakData")
local module = ...
local bot_health = D:conf("bot_health") or false
local bot_speed = D:conf("bot_speed") or false
local bot_regen = D:conf("bot_regen") or false
local BotSpeed = 600
local BotRegen = 2.5
local aimdelay_value = {0.8, 1}
local sniperaimdelay_value = {1.6, 2}
local diff_overhaul = D:conf("difficulty_overhaul") or false
if bot_speed then
	BotSpeed = bot_speed
end
if bot_regen then
	BotRegen = bot_regen
end
local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
module:post_hook(CharacterTweakData, "_init_spanish", function(self, presets)
	self.spanish.SPEED_WALK = BotSpeed
	self.spanish.SPEED_RUN = BotSpeed
end, false)

module:post_hook(CharacterTweakData, "_init_german", function(self, presets)
	self.german.SPEED_WALK = BotSpeed
	self.german.SPEED_RUN = BotSpeed
end, false)

module:post_hook(CharacterTweakData, "_init_russian", function(self, presets)
	self.russian.SPEED_WALK = BotSpeed
	self.russian.SPEED_RUN = BotSpeed
end, false)

module:post_hook(CharacterTweakData, "_init_american", function(self, presets)
	self.american.SPEED_WALK = BotSpeed
	self.american.SPEED_RUN = BotSpeed
end, false)

module:hook(50, CharacterTweakData, "_presets", function(self, tweak_data)
	local presets = module:call_orig(CharacterTweakData, "_presets", self, tweak_data)

	-- nerf shotgun reaction times
	if not diff_overhaul then
		presets.weapon.normal.r870.aim_delay = { 0, 0.2 }
		presets.weapon.good.r870.aim_delay = { 0, 0.2 }
		presets.weapon.expert.r870.aim_delay = { 0, 0.2 }
		presets.weapon.gang_member.r870.aim_delay = { 0, 0.2 }
	end
	if bot_health then
		presets.gang_member_damage.HEALTH_INIT = bot_health
	else
		presets.gang_member_damage.HEALTH_INIT = 75
	end
	presets.gang_member_damage.REGENERATE_TIME = BotRegen
	presets.gang_member_damage.REGENERATE_TIME_AWAY = BotRegen

	return presets
end, false)
if diff_overhaul then
	function CharacterTweakData:_set_easy()
		self:_multiply_all_hp(0.8, 1)
		self:_multiply_weapon_delay(self.presets.weapon.normal, 1.25)
		self:_multiply_weapon_delay(self.presets.weapon.good, 1.25)
		self:_multiply_weapon_delay(self.presets.weapon.expert, 1.25)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 1.25)
		self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
	end
	function CharacterTweakData:_set_normal()
		self:_multiply_all_hp(1, 1)
		self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
		self:_multiply_weapon_delay(self.presets.weapon.good, 1)
		self:_multiply_weapon_delay(self.presets.weapon.expert, 1)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 1)
		self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
	end
	function CharacterTweakData:_set_hard()
		self:_multiply_all_hp(1.2, 1)
		self:_multiply_all_speeds(1.05, 1.15)
		self:_multiply_weapon_delay(self.presets.weapon.normal, 0.75)
		self:_multiply_weapon_delay(self.presets.weapon.good, 0.75)
		self:_multiply_weapon_delay(self.presets.weapon.expert, 0.75)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 0.75)
		self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
		self.presets.gang_member_damage.TASED_TIME = 7.5
	end
	function CharacterTweakData:_set_overkill()
		self:_multiply_all_hp(1.5, 1.5)
		self:_multiply_all_speeds(1.15, 1.25)
		self:_multiply_weapon_delay(self.presets.weapon.normal, 0.5)
		self:_multiply_weapon_delay(self.presets.weapon.good, 0.5)
		self:_multiply_weapon_delay(self.presets.weapon.expert, 0.5)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 0.5)
		self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
		self.presets.gang_member_damage.TASED_TIME = 5
		self.presets.gang_member_damage.DOWNED_TIME = 25
		self.presets.gang_member_damage.INCAPACITATED_TIME = 25
	
	end
	function CharacterTweakData:_set_overkill_145()
		self:_multiply_all_hp(2, 1.55)
		self:_multiply_all_speeds(1.25, 1.35)
		self:_multiply_weapon_delay(self.presets.weapon.normal, 0.25)
		self:_multiply_weapon_delay(self.presets.weapon.good, 0.25)
		self:_multiply_weapon_delay(self.presets.weapon.expert, 0.25)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 0.25)
		self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
		self.presets.gang_member_damage.TASED_TIME = 3
		self.presets.gang_member_damage.DOWNED_TIME = 20
		self.presets.gang_member_damage.INCAPACITATED_TIME = 20
	end
	module:hook(CharacterTweakData, "_presets", function(self, tweak_data)
		local presets = module:call_orig(CharacterTweakData, "_presets", self, tweak_data)

		presets.weapon.gang_member.beretta92.aim_delay = {0, 0}
		presets.weapon.gang_member.beretta92.hit_chance = {
			near = {1, 1},
			far = {1, 1}
		}
		presets.weapon.gang_member.m4.aim_delay = {0, 0}
		presets.weapon.gang_member.m4.hit_chance = {
			near = {1, 1},
			far = {1, 1}
		}
		presets.weapon.gang_member.mp5.aim_delay = {0, 0}
		presets.weapon.gang_member.mp5.hit_chance = {
			near = {1, 1},
			far = {1, 1}
		}

		presets.weapon.normal.beretta92.aim_delay = aimdelay_value
		--presets.weapon.normal.beretta92.FALLOFF[3].dmg_mul = 0
		presets.weapon.normal.beretta92.FALLOFF[4].dmg_mul = 0
		presets.weapon.normal.c45.aim_delay = aimdelay_value
		--presets.weapon.normal.c45.FALLOFF[3].dmg_mul = 0
		presets.weapon.normal.c45.FALLOFF[4].dmg_mul = 0
		presets.weapon.normal.m4.aim_delay = aimdelay_value
		presets.weapon.normal.r870.aim_delay = aimdelay_value
		--presets.weapon.normal.r870.FALLOFF[4].dmg_mul = 0
		presets.weapon.normal.r870.FALLOFF[5].dmg_mul = 0
		presets.weapon.normal.r870.hit_chance = {
			near = {1, 1},
			far = {0, 0.8}
		}
		presets.weapon.normal.mp5.aim_delay = aimdelay_value
		presets.weapon.normal.mac11.aim_delay = aimdelay_value

		presets.weapon.good.beretta92.aim_delay = aimdelay_value
		--presets.weapon.good.beretta92.FALLOFF[3].dmg_mul = 0
		presets.weapon.good.beretta92.FALLOFF[4].dmg_mul = 0
		presets.weapon.good.c45.aim_delay = aimdelay_value
		--presets.weapon.good.c45.FALLOFF[3].dmg_mul = 0
		presets.weapon.good.c45.FALLOFF[4].dmg_mul = 0
		presets.weapon.good.m4.aim_delay = aimdelay_value
		presets.weapon.good.r870.aim_delay = aimdelay_value
		--presets.weapon.good.r870.FALLOFF[4].dmg_mul = 0
		presets.weapon.good.r870.FALLOFF[5].dmg_mul = 0
		presets.weapon.good.r870.hit_chance = {
			near = {1, 1},
			far = {0, 0.8}
		}
		presets.weapon.good.mp5.aim_delay = aimdelay_value
		presets.weapon.good.mac11.aim_delay = aimdelay_value

		presets.weapon.expert.beretta92.aim_delay = aimdelay_value
		--presets.weapon.expert.beretta92.FALLOFF[3].dmg_mul = 0
		presets.weapon.expert.beretta92.FALLOFF[4].dmg_mul = 0
		presets.weapon.expert.c45.aim_delay = aimdelay_value
		--presets.weapon.expert.c45.FALLOFF[3].dmg_mul = 0
		presets.weapon.expert.c45.FALLOFF[4].dmg_mul = 0
		presets.weapon.expert.m4.aim_delay = aimdelay_value
		presets.weapon.expert.r870.aim_delay = aimdelay_value
		--presets.weapon.expert.r870.FALLOFF[4].dmg_mul = 0
		presets.weapon.expert.r870.FALLOFF[5].dmg_mul = 0
		presets.weapon.expert.r870.hit_chance = {
			near = {1, 1},
			far = {0, 0}
		}
		presets.weapon.expert.mp5.aim_delay = aimdelay_value
		presets.weapon.expert.mac11.aim_delay = aimdelay_value

		presets.weapon.sniper.m4.aim_delay = sniperaimdelay_value
		presets.weapon.sniper.m4.focus_delay = 4
		return presets
	end, false)
end