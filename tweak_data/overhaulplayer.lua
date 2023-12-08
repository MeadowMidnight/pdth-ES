local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local diff_overhaul = D:conf("difficulty_overhaul") or false
local module = ...
local PlayerTweakDataHook = module:hook_class("PlayerTweakData")
if not is_singleplayer or not diff_overhaul then
	return
end
function PlayerTweakData:_set_easy()
	self.damage.ARMOR_INIT = 5
	self.damage.MIN_DAMAGE_INTERVAL = 0.4
	self.damage.TASED_TIME = 12.5
end
function PlayerTweakData:_set_normal()
	self.damage.ARMOR_INIT = 4
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
end
function PlayerTweakData:_set_hard()
	self.damage.ARMOR_INIT = 3
	self.damage.MIN_DAMAGE_INTERVAL = 0.3
	self.damage.DOWNED_TIME_DEC = 7
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.TASED_TIME = 7.5
	self.damage.REVIVE_HEALTH_STEPS = {0.6, 0.4, 0.2}
end
function PlayerTweakData:_set_overkill()
	self.damage.ARMOR_INIT = 2
	self.damage.MIN_DAMAGE_INTERVAL = 0.25
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.TASED_TIME = 5
	self.damage.REVIVE_HEALTH_STEPS = {0.5, 0.25}
end
function PlayerTweakData:_set_overkill_145()
	self.damage.ARMOR_INIT = 1
	self.damage.MIN_DAMAGE_INTERVAL = 0.2
	self.damage.DOWNED_TIME_DEC = 15
	self.damage.DOWNED_TIME_MIN = 0
	self.damage.REVIVE_HEALTH_STEPS = {0.2}
	self.damage.TASED_TIME = 5
end
module:post_hook(PlayerTweakDataHook, "init", function(self)
	self.damage.automatic_respawn_time = 0
end, false)