local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function TimerGui:_start(timer, current_timer)
	self._started = true
	self._done = false
	self._timer = timer * managers.player:toolset_value() or 5 
	self._current_timer = current_timer or self._timer
	self._gui_script.timer:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))
	self._gui_script.working_text:set_text(managers.localization:text(self._gui_working))
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), true)
	self._update_enabled = true
	self:post_event(self._start_event)
	self._gui_script.time_header_text:set_visible(true)
	self._gui_script.time_text:set_visible(true)
	self._gui_script.time_text:set_text(math.floor(self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
	self._unit:base():start()
	if Network:is_client() then
		return
	end
	self:_set_jamming_values()
end
