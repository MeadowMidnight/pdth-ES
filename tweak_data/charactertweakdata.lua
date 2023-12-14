local CharacterTweakData = module:hook_class("CharacterTweakData")
local module = ...
local bot_health = D:conf("bot_health") or false
local bot_speed = D:conf("bot_speed") or false
local bot_regen = D:conf("bot_regen") or false
local BotSpeed = 600
local BotRegen = 2.5
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

	presets.weapon.normal.r870.aim_delay = { 0, 0.2 }
	presets.weapon.good.r870.aim_delay = { 0, 0.2 }
	presets.weapon.expert.r870.aim_delay = { 0, 0.2 }
	presets.weapon.gang_member.r870.aim_delay = { 0, 0.2 }

	if bot_health then
		presets.gang_member_damage.HEALTH_INIT = bot_health
	else
		presets.gang_member_damage.HEALTH_INIT = 75
	end
	presets.gang_member_damage.REGENERATE_TIME = BotRegen
	presets.gang_member_damage.REGENERATE_TIME_AWAY = BotRegen

	return presets
end, false)
