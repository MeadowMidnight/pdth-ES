local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local diff_overhaul = D:conf("difficulty_overhaul") or false
local GroupHook = module:hook_class("GroupAITweakData")
if not diff_overhaul then
	return
end
function GroupAITweakData:_set_easy()
	self.max_nr_simultaneous_boss_types = 1
	self.besiege.assault.force = {15, 15, 15}
	self.street.assault.force.aggressive = {12, 12, 12}
	self.street.blockade.force.frontal = {14, 14, 14}
	self.street.blockade.force.defend = {6, 6, 6}
end
function GroupAITweakData:_set_normal()
	self.max_nr_simultaneous_boss_types = 2
	self.besiege.assault.force = {15, 15, 15}
	self.street.assault.force.aggressive = {16, 16, 16}
	self.street.blockade.force.frontal = {17, 17, 17}
	self.street.blockade.force.defend = {8, 8, 8}
end
function GroupAITweakData:_set_hard()
	self.max_nr_simultaneous_boss_types = 3
	self.besiege.assault.force = {20, 20, 20}
	self.street.assault.force.aggressive = {20, 20, 20}
	self.street.blockade.force.frontal = {20, 20, 20}
	self.street.blockade.force.defend = {10, 10, 10}
end
function GroupAITweakData:_set_overkill()
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.force = {25, 25, 25}
	self.street.assault.force.aggressive = {20, 20, 20}
	self.street.blockade.force.frontal = {20, 20, 20}
	self.street.blockade.force.defend = {10, 10, 10}
end
function GroupAITweakData:_set_overkill_145()
	self.max_nr_simultaneous_boss_types = 5
	self.besiege.assault.force = {30, 30, 30}
	self.street.assault.force.aggressive = {25, 25, 25}
	self.street.blockade.force.frontal = {20, 20, 20}
	self.street.blockade.force.defend = {10, 10, 10}
end
module:post_hook(GroupHook, "init", function(self)
	self.besiege.assault.force = {25, 25, 25}
	self.street.assault.force.aggressive = {20, 20, 20}
	self.street.assault.force.defensive = {0, 0, 0}
	self.street.blockade.force.frontal = {20, 20, 20}
	self.street.blockade.force.defend = {10, 10, 10}

	--self.besiege.assault.sustain_duration_min = {120, 120, 120}
--	self.besiege.assault.sustain_duration_max = {120, 120, 120}
	self.besiege.assault.sustain_duration_min = {20, 20, 20}
    self.besiege.assault.sustain_duration_max = {20, 20, 20}
	self.street.assault.sustain_duration_min = {150, 150, 150}
	self.street.assault.sustain_duration_max = {150, 150, 150}
	self.street.blockade.sustain_duration_min = {90, 90, 90}
	self.street.blockade.sustain_duration_max = {90, 90, 90}

	self.besiege.assault.delay = {60, 60, 60}
	self.street.assault.delay = {100, 100, 100}
	self.street.blockade.delay = {80, 80, 80}

	self.street.assault.build_duration = 1
	self.besiege.assault.build_duration = 1
	self.street.blockade.build_duration = 1

	self.besiege.assault.units = {
		swat = {1, 0, 0},
		swat_kevlar = {0.4, 1, 0.2},
		shield = {0.2, 0.5, 0.5},
		tank = {0, 0, 0.1},
		spooc = {0.2, 0.5, 1},
		taser = {0.05, 0.2, 0.3}
	}
	self.street.assault.units = {
		swat = {1, 0.5, 0},
		swat_kevlar = {0.4, 1, 0.2},
		shield = {0.2, 0.5, 0.5},
		tank = {0, 0, 0.1},
		spooc = {0.2, 0.5, 1},
		taser = {0.05, 0.2, 0.3}
	}
	self.street.blockade.units = {
		defend = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.4, 1, 1},
			shield = {0.1, 0.2, 0.3}
		},
		frontal = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.2, 0.5, 1},
			shield = {0, 0.1, 0.5},
			spooc = {0.1, 0.3, 0.4}
		},
		flank = {
			spooc = {1, 1, 1},
			taser = {1, 1, 1}
			--fbi_special = {0.001, 0.001, 0.001}
		}
	}
end, false)