local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local multi_spawns = D:conf("multi_spawns") or false
local GroupHook = module:hook_class("GroupAITweakData")
if not multi_spawns then
	return
end
module:post_hook(GroupHook, "_set_easy", function(self)
	self.street.assault.force.aggressive = {
		10,
		15,
		20
	}
end, false)
module:post_hook(GroupHook, "_set_overkill_145", function(self)
	self.besiege.assault.force = {
		25,
		35,
		35
	}
end, false)
module:post_hook(GroupHook, "init", function(self)
	self.besiege.assault.force = {
		25,
		25,
		25
	}
	self.besiege.recon.group_size = {
		4,
		4,
		4
	}
	self.besiege.recon.interval_variation = 7
	self.street.assault.force.aggressive = {
		20,
		23,
		25
	}
	self.street.blockade.force.defend = {
		9,
		9,
		9
	}
	self.street.blockade.force.frontal = {
		15,
		15,
		15
	}
end, false)