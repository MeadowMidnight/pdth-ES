local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
local NameTextProps =
{
    text      = "Enhanced Singleplayer mod is currently active in this heist.",
    color     = Color(0.5,0,0),
    font      = "fonts/font_univers_530_bold",
    font_size = 28 * tweak_data.scale.small_font_multiplier,
    align     = "middle",
    vertical  = "bottom",
    h         = 30,
    w         = 800,
    layer     = 5,
}

function _wtfbm_fade_in(o)
    local t = 2
    local c = o:color()
    
    while t > 0 do
        t = t - coroutine.yield()
        o:set_color(c:with_alpha(1 - (t/2)))
    end
    
    o:set_color(c:with_alpha(1))
end

function _wtfbm_fade_out(o)
    local t = 1
    local c = o:color()
    
    while t > 0 do
        t = t - coroutine.yield()
        o:set_color(c:with_alpha(t))
    end
    
    o:set_color(c:with_alpha(0))
end
local oldStartAudio = IngameWaitingForPlayersState._start_audio
function IngameWaitingForPlayersState:_start_audio(...)
    oldStartAudio(self, ...)
    local hud = managers.hud:script(self.LEVEL_INTRO_GUI)
    self._LabelName = hud.panel:text(NameTextProps)
    self._LabelName:set_position(630, 30)
    self._LabelName:animate(_wtfbm_fade_in)
end
--[[local oldUpdate = IngameWaitingForPlayersState.update
function IngameWaitingForPlayersState:update(t, dt)
    if self._delay_start_t and t > self._delay_start_t then
        self._LabelName:animate(_wtfbm_fade_out)
    end
    oldUpdate(self, t, dt)
end ]]