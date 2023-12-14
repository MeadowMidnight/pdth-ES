local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local module = ...
local rebalanced_weapons = D:conf("rebalanced_weapons") or false
local PlayerTweakDataHook = module:hook_class("PlayerTweakData")
module:post_hook(PlayerTweakDataHook, "init", function(self)
	self.movement_state.interaction_delay = 1
	if rebalanced_weapons then
		self.stances.glock.steelsight.zoom_fov = false
	end
end, false)
module:post_hook(PlayerTweakDataHook, "_set_easy", function(self)
	self.damage.automatic_respawn_time = 0
end, false)
module:post_hook(PlayerTweakDataHook, "_set_normal", function(self)
	self.damage.automatic_respawn_time = 0
end, false)

function PlayerTweakData:_set_hard()
	self.damage.ARMOR_INIT = 2
	self.damage.MIN_DAMAGE_INTERVAL = 0.3
	self.damage.DOWNED_TIME_DEC = 7
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.automatic_respawn_time = 0
end
function PlayerTweakData:_set_overkill()
	self.damage.ARMOR_INIT = 1
	self.damage.MIN_DAMAGE_INTERVAL = 0.3
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.automatic_respawn_time = 0
end
function PlayerTweakData:_set_overkill_145()
	self.damage.ARMOR_INIT = 1
	self.damage.MIN_DAMAGE_INTERVAL = 0.15
	self.damage.DOWNED_TIME_DEC = 15
	self.damage.DOWNED_TIME_MIN = 0
	self.damage.REVIVE_HEALTH_STEPS = {0.2}
	self.damage.automatic_respawn_time = 0
end