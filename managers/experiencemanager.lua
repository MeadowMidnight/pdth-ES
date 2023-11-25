local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
if not is_singleplayer then
	return
end
function ExperienceManager:_level_up()
	local target_tree = managers.upgrades:current_tree()
	managers.upgrades:aquire_target()
	self._global.level = self._global.level + 1
	self:_set_next_level_data(self._global.level + 1)
	local player = managers.player:player_unit()
	managers.challenges:check_active_challenges()
	if managers.groupai:state():is_AI_enabled() then
		if target_tree == 1 and managers.groupai:state():get_assault_mode() then
			managers.challenges:set_flag("aint_afraid")
		elseif target_tree == 2 and managers.statistics._last_kill == "sniper" then
			managers.challenges:set_flag("crack_bang")
		elseif target_tree == 3 and managers.achievment:get_script_data("player_reviving") then
			managers.challenges:set_flag("lay_on_hands")
		end
	end
	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_level_up", managers.network:session():local_peer():id(), self._global.level)
	end
	if self._global.level >= 145 then
		managers.challenges:set_flag("president")
		managers.challenges:set_flag("aint_afraid")
		managers.challenges:set_flag("crack_bang")
		managers.challenges:set_flag("lay_on_hands")
	end
end
function ExperienceManager:add_points(points, present_xp, debug)
	if not debug and managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end
	local has_noob_lube = false
	local has_nice_guy = false
	if crew_bonus == "noob_lube" or crew_bonus2 == "noob_lube" or crew_bonus3 == "noob_lube" then
		has_noob_lube = true
	end
	if crew_bonus == "nice_guy" or crew_bonus2 == "nice_guy" or crew_bonus3 == "nice_guy" then
		has_nice_guy = true
	end

	local multiplier = 1
	if has_noob_lube == true and has_nice_guy == true then
		multiplier = 1.44
	elseif has_noob_lube == true and has_nice_guy == false then
		multiplier = 1.2
	elseif has_noob_lube == false and has_nice_guy == true then
		multiplier = 1.2
	end
	points = math.floor(points * multiplier)
	if not managers.dlc:has_full_game() and self._global.level >= 10 then
		self._global.total = self._global.total + points
		self._global.next_level_data.current_points = 0
		self:present()
		managers.challenges:aquired_money()
		managers.statistics:aquired_money(points)
		return
	end
	if self._global.level >= self:level_cap() then
		self._global.total = self._global.total + points
		managers.challenges:aquired_money()
		managers.statistics:aquired_money(points)
		return
	end
	if present_xp then
		self:_present_xp(points)
	end
	local points_left = self._global.next_level_data.points - self._global.next_level_data.current_points
	if points < points_left then
		self._global.total = self._global.total + points
		self._global.next_level_data.current_points = self._global.next_level_data.current_points + points
		self:present()
		managers.challenges:aquired_money()
		managers.statistics:aquired_money(points)
		return
	end
	self._global.total = self._global.total + points_left
	self._global.next_level_data.current_points = self._global.next_level_data.current_points + points_left
	self:present()
	self:_level_up()
	managers.statistics:aquired_money(points_left)
	self:add_points(points - points_left)
end