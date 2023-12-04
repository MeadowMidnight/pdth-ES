local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault
	if not task_data.active then
		return
	end
	local t = self._t
	if task_data.phase == "anticipation" then
		if t > task_data.phase_end_t then
			managers.hud:start_assault()
			self:_set_rescue_state(false)
			task_data.phase = "build"
			task_data.phase_end_t = self._t + tweak_data.group_ai.besiege.assault.build_duration
			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)
		end
	elseif task_data.phase == "build" then
		if t > task_data.phase_end_t or self._drama_data.zone == "high" then
			task_data.phase = "sustain"
			task_data.phase_end_t = t + math.lerp(self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random())
		end
	elseif task_data.phase == "sustain" then
		if t > task_data.phase_end_t and not self._hunt_mode then
			local hostage_count = managers.groupai:state():hostage_count()
			local extratime = 10 * hostage_count
			if extratime > 40 then extratime = 40 end
			task_data.phase = "fade"
			task_data.use_smoke = false
			task_data.use_smoke_timer = t + 20
			task_data.phase_end_t = t + 10 + extratime
		end
	elseif t > task_data.phase_end_t - 8 and not task_data.said_retreat then
		if self._drama_data.amount < tweak_data.drama.assault_fade_end then
			task_data.said_retreat = true
			self:_police_announce_retreat()
		end
	elseif t > task_data.phase_end_t and self._drama_data.amount < tweak_data.drama.assault_fade_end then
		task_data.active = nil
		task_data.phase = nil
		task_data.said_retreat = nil
		if self._draw_drama then
			self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
		end
		self:_begin_regroup_task()
		return
	end
	local primary_target_area = task_data.target_areas[1]
	local area_data = self._area_data[primary_target_area]
	local area_safe = true
	for criminal_key, _ in pairs(area_data.criminal.units) do
		local criminal_data = self._criminals[criminal_key]
		if not criminal_data.status then
			local crim_area = criminal_data.tracker:nav_segment()
			if crim_area == primary_target_area then
				area_safe = nil
			end
		else
		end
	end
	if area_safe then
		local target_pos = managers.navigation._nav_segments[primary_target_area].pos
		local nearest_area, nearest_dis
		for criminal_key, criminal_data in pairs(self._criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)
				if not nearest_dis or nearest_dis > dis then
					nearest_dis = dis
					nearest_area = criminal_data.tracker:nav_segment()
				end
			end
		end
		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end
	if task_data.phase == "anticipation" then
		local spawn_threshold = math.max(0, self._police_force_max - self._police_force - 5)
		if spawn_threshold > 0 then
			local nr_wanted = math.min(spawn_threshold, task_data.force - self._police_force)
			if nr_wanted > 0 then
				nr_wanted = math.min(3, nr_wanted)
				local spawn_points = self:_find_spawn_points_near_area(primary_target_area, nr_wanted, nil, 10000, callback(self, self, "_verify_anticipation_spawn_point"))
				if spawn_points then
					local objectives = {}
					local function complete_clbk(chatter_unit)
						if not chatter_unit:sound():speaking(self._t) and tweak_data.character[chatter_unit:base()._tweak_table].chatter.ready then
							self:chk_say_enemy_chatter(chatter_unit, chatter_unit:movement():m_pos(), "ready")
						end
					end
					for _, sp_data in ipairs(spawn_points) do
						local new_objective = {
							type = "investigate_area",
							nav_seg = sp_data.nav_seg,
							attitude = "avoid",
							stance = "hos",
							interrupt_on = "obstructed",
							scan = true,
							complete_clbk = complete_clbk
						}
						table.insert(objectives, new_objective)
					end
					GroupAIStateStreet._spawn_cops_with_objectives(self, spawn_points, objectives, tweak_data.group_ai.besiege.assault.units)
				end
			end
		end
		return
	end
	if task_data.phase ~= "fade" and task_data.phase ~= "anticipation" then
		local spawn_threshold = math.max(0, self._police_force_max - self._police_force)
		if spawn_threshold > 0 then
			local nr_wanted = math.min(spawn_threshold, task_data.force - self._police_force)
			if nr_wanted > 0 then
				local used_event
				if task_data.use_spawn_event then
					task_data.use_spawn_event = false
					if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
						used_event = true
					end
				end
				if not used_event then
					nr_wanted = math.min(3, nr_wanted)
					local spawn_points = self:_find_spawn_points_near_area(primary_target_area, nr_wanted)
					if spawn_points then
						self:_spawn_cops_to_recon(primary_target_area, spawn_points, "engage", "assault")
					end
				end
			end
		end
		local existing_cops = self:_find_surplus_cops_around_area(primary_target_area, 100, 0)
		if existing_cops then
			self:_assign_cops_to_recon(primary_target_area, existing_cops, "engage")
		end
	end
	if t > task_data.use_smoke_timer then
		task_data.use_smoke = true
	end
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local shoot_smoke, shooter_pos, shooter_u_data, detonate_pos
		local duration = 0
		if self._smoke_grenade_queued then
			shoot_smoke = true
			shooter_pos = self._smoke_grenade_queued[1]
			detonate_pos = self._smoke_grenade_queued[1]
			duration = self._smoke_grenade_queued[2]
		else
			local door_found
			local shoot_from_neighbours = managers.navigation:get_nav_seg_neighbours(primary_target_area)
			for u_key, u_data in pairs(self._police) do
				local nav_seg = u_data.tracker:nav_segment()
				if nav_seg == primary_target_area then
					task_data.use_smoke = false
					door_found = nil
					break
				elseif not door_found then
					local door_ids = shoot_from_neighbours[nav_seg]
					if door_ids and tweak_data.character[u_data.unit:base()._tweak_table].use_smoke then
						local random_door_id = door_ids[math.random(#door_ids)]
						if type(random_door_id) == "number" then
							door_found = managers.navigation._room_doors[random_door_id]
							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data
						end
					end
				end
			end
			if door_found then
				detonate_pos = mvector3.copy(door_found.center)
				shoot_smoke = true
			end
		end
		if shoot_smoke then
			task_data.use_smoke_timer = t + math.lerp(10, 40, math.rand(0, 1) ^ 0.5)
			task_data.use_smoke = false
			if Network:is_server() then
				local ignore_ctrl
				if self._smoke_grenade_queued and self._smoke_grenade_queued[3] then
					ignore_ctrl = true
				end
				managers.network:session():send_to_peers("sync_smoke_grenade", detonate_pos, shooter_pos, duration)
				self:sync_smoke_grenade(detonate_pos, shooter_pos, duration)
				if ignore_ctrl then
					self._smoke_grenade_ignore_control = true
				end
				if shooter_u_data and not shooter_u_data.unit:sound():speaking(self._t) and tweak_data.character[shooter_u_data.unit:base()._tweak_table].chatter.smoke then
					self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "smoke")
				end
			end
		end
	end
end
function GroupAIStateBesiege:is_smoke_grenade_active()
	return false
end