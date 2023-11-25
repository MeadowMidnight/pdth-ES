local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
function SecurityCamera:generate_cooldown(amount)
	managers.hint:show_hint("destroyed_security_camera")
	managers.statistics:camera_destroyed()
	managers.experience:add_points(200, true)
	managers.challenges:set_flag("kill_cameras")
end
