local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local XPPoints = 500
if not Global.game_settings then
	return
end
if Global.game_settings.difficulty == "easy" then
	XPPoints = 500
elseif Global.game_settings.difficulty == "normal" then
	XPPoints = 1000
elseif Global.game_settings.difficulty == "overkill" then
	XPPoints = 2000
elseif Global.game_settings.difficulty == "overkill_145" then
	XPPoints = 2500
else
	XPPoints = 1500
end
function ChristmasPresentBase:init(unit)
	UnitBase.init(self, unit, false)
	self._unit = unit
end

function ChristmasPresentBase:take_money(unit)
	managers.challenges:set_flag("take_christmas_present")
	managers.experience:add_points(XPPoints, true)
	local params = {}
	params.effect = Idstring("effects/particles/environment/player_snowflakes")
	params.position = Vector3()
	params.rotation = Rotation()
	World:effect_manager():spawn(params)
	managers.hud._sound_source:post_event("jingle_bells")
	Network:detach_unit(self._unit)
	self._unit:set_slot(0)
end
