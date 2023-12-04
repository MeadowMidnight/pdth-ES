local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local TweakDataHook = module:hook_class("TweakData")
module:post_hook(TweakDataHook, "init", function(self)
	self.interaction.hack_ipad_jammed.timer = 7.5
	self.interaction.drill_jammed.timer = 7.5
	self.interaction.stash_planks.equipment_consume = false
	self.interaction.stash_planks_pickup.timer = 1
	self.interaction.stash_planks.timer = 3
	self.interaction.patientpaper_pickup.timer = 1
	self.interaction.hospital_sentry.timer = 1
	self.interaction.c4.timer = 2
	self.interaction.c4_diffusible.timer = 0.25
	self.interaction.c4_special.timer = 2
	self.interaction.suburbia_money_wrap.timer = 1.5
	self.interaction.money_wrap.timer = 1.5
	self.interaction.intimidate.timer = 1
	self.interaction.intimidate_and_search.timer = 1
	self.interaction.secret_stash_trunk_crowbar.timer = 10
	self.interaction.suburbia_iron_gate_crowbar.timer = 4
	self.weapon["mac11"].alert_size = 500
	self.weapon["beretta92"].alert_size = 500
	self.weapon["beretta92_npc"].alert_size = 500
	self.weapon["m4_npc"].alert_size = 500
	self.weapon["mp5_npc"].alert_size = 500
	self.weapon["raging_bull_npc"].alert_size = 500
	self.character.presets["gang_member_damage"].hurt_severity = {
		1,
		1,
		1,
		1
	 }
end, false)
function TweakData:_set_easy()
	self.player:_set_easy()
	self.character:_set_easy()
	self.group_ai:_set_easy()
	self.experience_manager.total_level_objectives = 1000
	self.experience_manager.total_criminals_finished = 200
	self.experience_manager.total_objectives_finished = 750
	self.experience_manager.civilians_killed = 50
	self.experience_manager.values.size03 = 200
	self.experience_manager.values.size12 = 200
	self.experience_manager.values.size20 = 400
	self.experience_manager.values.size16 = 500
	self.experience_manager.values.size06 = 200
	self.experience_manager.values.size18 = 400
end
function TweakData:_set_normal()
	self.player:_set_normal()
	self.character:_set_normal()
	self.group_ai:_set_normal()
	self.experience_manager.total_level_objectives = 2000
	self.experience_manager.total_criminals_finished = 400
	self.experience_manager.total_objectives_finished = 1500
	self.experience_manager.civilians_killed = 100
	self.experience_manager.values.size03 = 400
	self.experience_manager.values.size12 = 400
	self.experience_manager.values.size20 = 800
	self.experience_manager.values.size16 = 1000
	self.experience_manager.values.size06 = 400
	self.experience_manager.values.size18 = 800
end
function TweakData:_set_hard()
	self.player:_set_hard()
	self.character:_set_hard()
	self.group_ai:_set_hard()
	self.experience_manager.total_level_objectives = 3000
	self.experience_manager.total_criminals_finished = 600
	self.experience_manager.total_objectives_finished = 2250
	self.experience_manager.civilians_killed = 150
	self.experience_manager.values.size03 = 600
	self.experience_manager.values.size12 = 600
	self.experience_manager.values.size20 = 1200
	self.experience_manager.values.size16 = 1500
	self.experience_manager.values.size06 = 600
	self.experience_manager.values.size18 = 1200
end
function TweakData:_set_overkill()
	self.player:_set_overkill()
	self.character:_set_overkill()
	self.group_ai:_set_overkill()
	self.experience_manager.total_level_objectives = 4000
	self.experience_manager.total_criminals_finished = 800
	self.experience_manager.total_objectives_finished = 3000
	self.experience_manager.civilians_killed = 200
	self.experience_manager.values.size03 = 800
	self.experience_manager.values.size12 = 800
	self.experience_manager.values.size20 = 1600
	self.experience_manager.values.size16 = 2000
	self.experience_manager.values.size06 = 800
	self.experience_manager.values.size18 = 1600
end
function TweakData:_set_overkill_145()
	self.player:_set_overkill_145()
	self.character:_set_overkill_145()
	self.group_ai:_set_overkill_145()
	self.experience_manager.total_level_objectives = 6000
	self.experience_manager.total_criminals_finished = 1200
	self.experience_manager.total_objectives_finished = 4500
	self.experience_manager.civilians_killed = 300
	self.experience_manager.values.size03 = 1000
	self.experience_manager.values.size12 = 1000
	self.experience_manager.values.size20 = 2000
	self.experience_manager.values.size16 = 2500
	self.experience_manager.values.size06 = 1000
	self.experience_manager.values.size18 = 2000
end