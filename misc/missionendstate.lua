local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
module:hook(MissionEndState, "at_enter", function(self, old_state, params)
    module:call_orig(MissionEndState, "at_enter", self, old_state, params)
    if self._success and crew_bonus == "noob_lube" and crew_bonus2 == "noob_lube" and crew_bonus3 == "noob_lube" and tweak_data:difficulty_to_index(Global.game_settings.difficulty) >= 4 then
        managers.challenges:set_flag("noob_herder")
    elseif self._success and managers.player:crew_bonus_in_slot(1) == "more_ammo" and managers.player:equipment_in_slot(1) == "sentry_gun" and managers.player:equipment_in_slot(2) == "toolset" then
        local plr_inv = managers.player:player_unit():inventory()
		if plr_inv:unit_by_selection(1):base():get_name_id() == "glock" and plr_inv:unit_by_selection(2):base():get_name_id() == "ak47" or plr_inv:unit_by_selection(1):base():get_name_id() == "glock" and plr_inv:unit_by_selection(2):base():get_name_id() == "m79" then
            managers.challenges:set_flag("det_gadget")
        end
    end
end, false)
