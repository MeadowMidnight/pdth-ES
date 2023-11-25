local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function SecurityLockGui:_start(bar, timer, current_timer)
	self._current_bar = bar
	self._started = true
	self._done = false
	self._timer = timer * managers.player:toolset_value() or 5
	self._current_timer = current_timer or self._timer
	self._gui_script["timer_icon" .. self._current_bar]:set_image("units/world/architecture/secret_stash/props_textures/security_station_locked_df")
	self._gui_script["timer" .. self._current_bar]:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))
	self._gui_script.working_text:set_visible(false)
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), true)
	self._update_enabled = true
	self:post_event(self._start_event)
	self._gui_script.time_header_text:set_visible(true)
	self._gui_script.time_text:set_visible(true)
	self._gui_script.time_text:set_text(math.floor(self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
	if Network:is_client() then
		return
	end
end
