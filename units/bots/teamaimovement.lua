local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local module = ...
local bot_arrest = D:conf("bot_arrest") or false
if not is_singleplayer or not bot_arrest then
	return
end
function TeamAIMovement:on_SPOOCed()
	return
end
