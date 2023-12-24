local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function TeamAILogicIdle.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}
	my_data.detection = tweak_data.character[data.unit:base()._tweak_table].detection.idle
	my_data.enemy_detect_slotmask = managers.slot:get_mask("enemies")
	my_data.ai_visibility_slotmask = managers.slot:get_mask("AI_visibility")
	my_data.rsrv_pos = {}
	local old_internal_data = data.internal_data
	if old_internal_data then
		my_data.detected_enemies = old_internal_data.detected_enemies or {}
		my_data.rsrv_pos = old_internal_data.rsrv_pos or my_data.rsrv_pos
		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover
			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover
			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end
	else
		my_data.detected_enemies = {}
	end
	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	if not data.unit:movement():cool() then
		my_data.detection_task_key = "TeamAILogicIdle._update_enemy_detection" .. key_str
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._update_enemy_detection, data, data.t)
	end
	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end
	my_data.stare_path_search_id = "stare" .. key_str
	my_data.relocate_chk_t = 0
	CopLogicBase._reset_attention(data)
	data.unit:movement():set_allow_fire(false)
	if managers.groupai:state():player_weapons_hot() then
		data.unit:movement():set_stance("hos")
	end
	local objective = data.objective
	local entry_action = enter_params and enter_params.action
	if objective then
		if objective.type == "revive" then
			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end
			local success
			local revive_unit = objective.follow_unit
			if revive_unit:interaction() then
				if revive_unit:interaction():active() and data.unit:brain():action_request(objective.action) then
					revive_unit:interaction():interact_start(data.unit)
					success = true
				end
			elseif revive_unit:character_damage():arrested() then
				if data.unit:brain():action_request(objective.action) then
					revive_unit:character_damage():pause_arrested_timer()
					success = true
				end
			elseif revive_unit:character_damage():need_revive() and data.unit:brain():action_request(objective.action) then
				revive_unit:character_damage():pause_downed_timer()
				success = true
			end
			if success then
				my_data.performing_act_objective = objective
				my_data.reviving = revive_unit
				my_data.acting = true
				my_data.revive_complete_clbk_id = "TeamAILogicIdle_revive" .. tostring(data.key)
				local revive_t = TimerManager:game():time() + (objective.interact_delay or 0)
				CopLogicBase.add_delayed_clbk(my_data, my_data.revive_complete_clbk_id, callback(TeamAILogicIdle, TeamAILogicIdle, "clbk_revive_complete", data), revive_t)
				if not revive_unit:character_damage():arrested() then
					local suffix = "a"
					local downed_time = revive_unit:character_damage():down_time()
					if downed_time <= tweak_data.player.damage.DOWNED_TIME_MIN then
						suffix = "c"
					elseif downed_time == tweak_data.player.damage.DOWNED_TIME_MIN + tweak_data.player.damage.DOWNED_TIME_DEC then
						suffix = "c"
					elseif downed_time == 5 then
						suffix = "c"
					end
					data.unit:sound():say("s09" .. suffix, true)
				end
			else
				data.unit:brain():set_objective()
				return
			end
		elseif objective.type == "act" then
			if data.unit:brain():action_request(objective.action) then
				my_data.acting = true
			end
			my_data.performing_act_objective = objective
			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end
		elseif objective.type == "follow" then
		end
		if objective.scan then
			my_data.scan = true
			if not my_data.acting then
				my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. tostring(data.key)
				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end
		end
	end
end