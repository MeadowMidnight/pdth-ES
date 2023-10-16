-- This code is a mess, but personally I don't really care anymore. Hopefully I can finally stop working on this mod.
local module = ...
local crew_bonus = D:conf("crew_bonus_1") or false
local crew_bonus2 = D:conf("crew_bonus_2") or false
local crew_bonus3 = D:conf("crew_bonus_3") or false
local vanilla_weapons = D:conf("vanilla_weapons") or false
local vanilla_bonuses = D:conf("vanilla_bonuses") or false
local bot_health = D:conf("bot_health") or false
local bot_speed = D:conf("bot_speed") or false
local bot_regen = D:conf("bot_speed") or false
local protector_multi = 1.5
local reload_multi = 1.2
local sharp_multi = 0.75
if vanilla_bonuses then
    local protector_multi = 1.1
    local reload_multi = 1.1
    local sharp_multi = 0.9
end
function Check_Singleplayer() -- simple function to check if the game is on singleplayer.
    local is_singleplayer = Global.game_settings and Global.game_settings.single_player
    if not is_singleplayer then
	    return false
    else
        return true
    end
end

local disable_collision = function(unit) -- Function to stop bag collision.
	for index = 0, unit:num_bodies() - 1, 1 do
		local body = unit:body(index)

		if body then
			body:set_collisions_enabled(false)
			body:set_collides_with_mover(false)
			body:set_enabled(false)
		end
	end
end

if RequiredScript == "lib/network/matchmaking/networkaccountsteam" then -- Stop statistics from being published into Steam.
    local NetworkAccountSTEAM = module:hook_class("NetworkAccountSTEAM")

    module:hook(NetworkAccountSTEAM, "publish_statistics", function(self, stats, success, ...) end)
    function NetworkAccountSTEAM:stats_disabled()
        return true
    end
end

if RequiredScript == "lib/managers/menumanager" then
    function MenuManager:toggle_chatinput() -- Enable the chat...
        if Application:editor() then
            return
        end
    
        if SystemInfo:platform() ~= Idstring("WIN32") then
            return
        end
    
        if self:active_menu() then
            return
        end
        
        if managers.hud then
            managers.hud:toggle_chatinput()
        end
    
    end
    module:hook("OnMenuSetup", "OnMenuSetup_HideMenuItems", "menu_main", function(self, menu, nodes)
        self:update_menu_item(nodes, "main", "play_campaign", { visible_callback = "hide_unless_option_set" }) -- Hide the multiplayer option in the main menu.
    end)
end

if RequiredScript == "lib/units/weapons/raycastweaponbase" and Check_Singleplayer() then -- Stop bullets from colliding into bots and weapon-related crew bonus functions.
    local init_original = RaycastWeaponBase.init
    local setup_original = RaycastWeaponBase.setup

    function RaycastWeaponBase:init(...)
	    init_original(self, ...)
	    self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
    end

    function RaycastWeaponBase:setup(...)
	    setup_original(self, ...)
	    self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
    end

    function RaycastWeaponBase:reload_speed_multiplier()
        if crew_bonus == "speed_reloaders" or crew_bonus2 == "speed_reloaders" or crew_bonus3 == "speed_reloaders" then
            local multiplier = managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
            multiplier = multiplier * reload_multi
            return multiplier
        else
            local multiplier = managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
            return multiplier
        end
    end

    function RaycastWeaponBase:damage_multiplier()
        local multiplier = managers.player:upgrade_value(self._name_id, "damage_multiplier", 1)
        if crew_bonus == "aggressor" or crew_bonus2 == "aggressor" or crew_bonus3 == "aggressor" then
            multiplier = multiplier * 1.1
            return multiplier
        else
            return multiplier
        end
    end

    function RaycastWeaponBase:spread_multiplier()
        local multiplier = managers.player:upgrade_value(self._name_id, "spread_multiplier", 1)
        multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 1)
        if crew_bonus == "sharpshooters" or crew_bonus2 == "sharpshooters" or crew_bonus3 == "sharpshooters" then
             multiplier = multiplier * sharp_multi
             return multiplier
        else
             return multiplier
        end
        return multiplier
    end

    function RaycastWeaponBase:replenish()
        local ammo_max_multiplier = managers.player:equipped_upgrade_value("extra_start_out_ammo", "player", "extra_ammo_multiplier")
        if crew_bonus == "big_game_hunters" or crew_bonus2 == "big_game_hunters" or crew_bonus3 == "big_game_hunters" then
            ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * 1.15
        else
            ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * managers.player:synced_crew_bonus_upgrade_value("more_ammo", 1, true)
        end
        self._ammo_max_per_clip = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")
        self._ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") * self._ammo_max_per_clip) * ammo_max_multiplier)
        self._ammo_total = self._ammo_max
        self._ammo_remaining_in_clip = self._ammo_max_per_clip
        self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
        self:update_damage()
    end

end
if RequiredScript == "lib/units/weapons/grenades/m79grenadebase" and Check_Singleplayer() then -- Ditto, but with GL40 shots.
    local init_original = M79GrenadeBase.init
    function M79GrenadeBase:init(unit)
	    init_original(self, unit)
	    self._collision_slotmask = self._collision_slotmask - World:make_slot_mask(16)
    end
end
if RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" and Check_Singleplayer() then -- Stop doctor bag collision.
	local DoctorBagBase = module:hook_class("DoctorBagBase")
	module:post_hook(50, DoctorBagBase, "setup", function(self, ...)
		disable_collision(self._unit)
	end)
end
if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" and Check_Singleplayer() then -- Stop ammo bag collision.
    local AmmoBagBase = module:hook_class("AmmoBagBase")
	module:post_hook(50, AmmoBagBase, "setup", function(self, ...)
		disable_collision(self._unit)
	end)
end
if RequiredScript == "lib/tweak_data/charactertweakdata" and Check_Singleplayer() then -- Bot stat changes.
    local CharacterTweakData = module:hook_class("CharacterTweakData")
    local BotSpeed = 600
    local BotRegen = 2.5
    if bot_speed then
        BotSpeed = bot_speed
    end
    if bot_regen then
        BotRegen = bot_regen
    end
    module:post_hook(CharacterTweakData, "_init_spanish", function(self, presets)
        self.spanish.SPEED_WALK = BotSpeed
        self.spanish.SPEED_RUN = BotSpeed
    end, false)
    
    module:post_hook(CharacterTweakData, "_init_german", function(self, presets)
        self.german.SPEED_WALK = BotSpeed
        self.german.SPEED_RUN = BotSpeed
    end, false)
    
    module:post_hook(CharacterTweakData, "_init_russian", function(self, presets)
        self.russian.SPEED_WALK = BotSpeed
        self.russian.SPEED_RUN = BotSpeed
    end, false)
    
    module:post_hook(CharacterTweakData, "_init_american", function(self, presets)
        self.american.SPEED_WALK = BotSpeed
        self.american.SPEED_RUN = BotSpeed
    end, false)

    module:hook(50, CharacterTweakData, "_presets", function(self, tweak_data)
        local presets = module:call_orig(CharacterTweakData, "_presets", self, tweak_data)

        -- nerf shotgun reaction times
        presets.weapon.normal.r870.aim_delay = { 0, 0.2 }
        presets.weapon.good.r870.aim_delay = { 0, 0.2 }
        presets.weapon.expert.r870.aim_delay = { 0, 0.2 }
        presets.weapon.gang_member.r870.aim_delay = { 0, 0.2 }
        if bot_health then
            presets.gang_member_damage.HEALTH_INIT = bot_health
        else
            presets.gang_member_damage.HEALTH_INIT = 75
        end
        --presets.gang_member_damage.HEALTH_INIT = 75
        presets.gang_member_damage.REGENERATE_TIME = BotRegen
        presets.gang_member_damage.REGENERATE_TIME_AWAY = BotRegen
    
        return presets
    end, false)
end
if RequiredScript == "lib/units/player_team/teamaidamage" and Check_Singleplayer() then -- Bots will now stop attempting to "dodge" attacks, and the rest is further setup for bot HP being shown in HUD.
    function TeamAIDamage:inc_dodge_count(n)
        return
    end
    local TeamAIDamage = module:hook_class("TeamAIDamage")
	module:post_hook(55, TeamAIDamage, "_regenerated", function(self)
		managers.hud:set_mugshot_health(self._unit:unit_data().mugshot_id, self._health_ratio)
	end, false)

	module:hook(55, TeamAIDamage, "_apply_damage", function(self, attack_data, result)
		local damage_percent, health_subtracted =
			module:call_orig(TeamAIDamage, "_apply_damage", self, attack_data, result)
		if health_subtracted > 0 then
			managers.hud:set_mugshot_health(self._unit:unit_data().mugshot_id, self._health_ratio)
			if self._unit:network() then
				local hp = math.round(self._health_ratio * 100)
				self._unit:network():send("set_health", math.clamp(hp, 0, 100))
			end
		end
		return damage_percent, health_subtracted
	end, true)
end
if RequiredScript == "lib/units/player_team/teamaimovement" and Check_Singleplayer() then -- Bots will no longer get arrested by cloakers.
    function TeamAIMovement:on_SPOOCed()
        return
    end
end
if RequiredScript == "lib/units/props/timergui" and Check_Singleplayer() then -- Toolkit now reduces most timers by 30%.
    function TimerGui:_start(timer, current_timer)
        local is_cf = Global.level_data.level_id == "suburbia"
        local is_dh = Global.level_data.level_id == "diamond_heist"
        local is_fwb = Global.level_data.level_id == "bank"
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
end
if RequiredScript == "lib/tweak_data/tweakdata" and Check_Singleplayer() then -- Interaction, weapon and equipment changes.
    local TweakDataHook = module:hook_class("TweakData")
    module:post_hook(TweakDataHook, "init", function(self)
	    self.interaction.hack_ipad_jammed.timer = 7.5
        self.interaction.drill_jammed.timer = 7.5
	    self.interaction.stash_planks.equipment_consume = false
	    self.interaction.stash_planks_pickup.timer = 1
	    self.interaction.stash_planks.timer = 3
	    self.interaction.patientpaper_pickup.timer = 1
        self.interaction.hospital_sentry.timer = 1
	    self.interaction.c4.timer = 2
	    self.interaction.c4_diffusible.timer = 0.25
	    self.interaction.c4_special.timer = 2
        self.interaction.suburbia_money_wrap.timer = 1.5
	    self.interaction.money_wrap.timer = 1.5
	    self.interaction.intimidate.timer = 1
	    self.interaction.intimidate_and_search.timer = 1
        self.interaction.secret_stash_trunk_crowbar.timer = 10
        self.interaction.suburbia_iron_gate_crowbar.timer = 4
        self.weapon["mac11"].alert_size = 500
        self.weapon["beretta92"].alert_size = 500
        self.weapon["beretta92_npc"].alert_size = 500
        self.weapon["m4_npc"].alert_size = 500
        self.weapon["mp5_npc"].alert_size = 500
        self.weapon["raging_bull_npc"].alert_size = 500
    end, false)
    function TweakData:_set_easy()
        self.player:_set_easy()
        self.character:_set_easy()
        self.group_ai:_set_easy()
        self.experience_manager.total_level_objectives = 1000
        self.experience_manager.total_criminals_finished = 200
        self.experience_manager.total_objectives_finished = 750
        self.experience_manager.civilians_killed = 50
        self.experience_manager.values.size03 = 200
        self.experience_manager.values.size12 = 200
        self.experience_manager.values.size20 = 400
        self.experience_manager.values.size16 = 500
        self.experience_manager.values.size06 = 200
        self.experience_manager.values.size18 = 400
    end
    function TweakData:_set_normal()
        self.player:_set_normal()
        self.character:_set_normal()
        self.group_ai:_set_normal()
        self.experience_manager.total_level_objectives = 2000
        self.experience_manager.total_criminals_finished = 400
        self.experience_manager.total_objectives_finished = 1500
        self.experience_manager.civilians_killed = 100
        self.experience_manager.values.size03 = 400
        self.experience_manager.values.size12 = 400
        self.experience_manager.values.size20 = 800
        self.experience_manager.values.size16 = 1000
        self.experience_manager.values.size06 = 400
        self.experience_manager.values.size18 = 800
    end
    function TweakData:_set_hard()
        self.player:_set_hard()
        self.character:_set_hard()
        self.group_ai:_set_hard()
        self.experience_manager.total_level_objectives = 3000
        self.experience_manager.total_criminals_finished = 600
        self.experience_manager.total_objectives_finished = 2250
        self.experience_manager.civilians_killed = 150
        self.experience_manager.values.size03 = 600
        self.experience_manager.values.size12 = 600
        self.experience_manager.values.size20 = 1200
        self.experience_manager.values.size16 = 1500
        self.experience_manager.values.size06 = 600
        self.experience_manager.values.size18 = 1200
    end
    function TweakData:_set_overkill()
        self.player:_set_overkill()
        self.character:_set_overkill()
        self.group_ai:_set_overkill()
        self.experience_manager.total_level_objectives = 4000
        self.experience_manager.total_criminals_finished = 800
        self.experience_manager.total_objectives_finished = 3000
        self.experience_manager.civilians_killed = 200
        self.experience_manager.values.size03 = 800
        self.experience_manager.values.size12 = 800
        self.experience_manager.values.size20 = 1600
        self.experience_manager.values.size16 = 2000
        self.experience_manager.values.size06 = 800
        self.experience_manager.values.size18 = 1600
    end
    function TweakData:_set_overkill_145()
        self.player:_set_overkill_145()
        self.character:_set_overkill_145()
        self.group_ai:_set_overkill_145()
        self.experience_manager.total_level_objectives = 6000
        self.experience_manager.total_criminals_finished = 1200
        self.experience_manager.total_objectives_finished = 4500
        self.experience_manager.civilians_killed = 300
        self.experience_manager.values.size03 = 1000
        self.experience_manager.values.size12 = 1000
        self.experience_manager.values.size20 = 2000
        self.experience_manager.values.size16 = 2500
        self.experience_manager.values.size06 = 1000
        self.experience_manager.values.size18 = 2000
    end
end
if RequiredScript == "lib/tweak_data/playertweakdata" and Check_Singleplayer() then -- Shouting cooldown is reduced to 1 second instead of 1.5 and fixes ADS inconsistency with STRYK.
    local PlayerTweakDataHook = module:hook_class("PlayerTweakData")
    module:post_hook(PlayerTweakDataHook, "init", function(self)
	    self.movement_state.interaction_delay = 1
        if not vanilla_weapons then
            self.stances.glock.steelsight.zoom_fov = false
        end
    end, false)
    function PlayerTweakData:_set_overkill_145()
        self.damage.ARMOR_INIT = 1
        self.damage.MIN_DAMAGE_INTERVAL = 0.15
        self.damage.DOWNED_TIME_DEC = 15
        self.damage.DOWNED_TIME_MIN = 0 -- Stops bots from doing clutch revives.
        self.damage.REVIVE_HEALTH_STEPS = {0.2}
    end
end
if RequiredScript == "lib/tweak_data/equipmentstweakdata" and Check_Singleplayer() then -- Changes to all deployables and certain mission equipment items that weren't "solo friendly"
    local EquipmentsTweakData = module:hook_class("EquipmentsTweakData")

    module:post_hook(EquipmentsTweakData, "init", function(self)
	    self.ammo_bag = {
		    icon = "equipment_ammo_bag",
		    use_function_name = "use_ammo_bag",
		    quantity = 2,
		    text_id = "debug_ammo_bag",
		    description_id = "des_ammo_bag",
	    }
	    self.doctor_bag = {
		    icon = "equipment_doctor_bag",
		    use_function_name = "use_doctor_bag",
		    quantity = 2,
		    text_id = "debug_doctor_bag",
		    description_id = "des_doctor_bag",
	    }
	    self.sentry_gun = {
		    icon = "equipment_sentry",
		    use_function_name = "use_sentry_gun",
		    quantity = 4,
		    text_id = "debug_sentry_gun",
		    description_id = "des_sentry_gun",
	    }
        self.trip_mine = {
            icon = "equipment_trip_mine",
            use_function_name = "use_trip_mine",
            quantity = 4,
            text_id = "debug_trip_mine",
            description_id = "des_trip_mine"
        }
        self.specials.cable_tie = {
            text_id = "debug_equipment_cable_tie",
            icon = "equipment_cable_ties",
            quantity = 8,
            extra_quantity = {
                equipped_upgrade = "extra_cable_tie",
                category = "extra_cable_tie",
                upgrade = "quantity"
            }
        }
        self.specials.thermite = {
            text_id = "debug_equipment_thermite",
            icon = "equipment_thermite",
            action_message = "thermite_obtained",
            quantity = 2,
            sync_possession = true
        }
        self.specials.gas = {
            text_id = "debug_equipment_gas",
            icon = "equipment_thermite",
            action_message = "gas_obtained",
            quantity = 2,
            sync_possession = true
        }
        self.specials.c4 = {
            text_id = "debug_equipment_c4",
            icon = "equipment_c4",
            action_message = "c4_obtained",
            quantity = 9,
            sync_possession = true
        }
        self.specials.blood_sample = {
            text_id = "debug_equipment_blood_sample",
            icon = "equipment_vial",
            quantity = 4,
            sync_possession = true
        }
    end)
end
if RequiredScript == "lib/managers/missionmanager" and Check_Singleplayer() then -- Overdrill can be activated in solo.
    local MissionScript = module:hook_class("MissionScript")
    module:post_hook(MissionScript, "init", function(self)
        local level = Global.level_data.level_id
        if level == "bank" then
        for _, id in pairs({ 104145, 104152, 104153, 104154 }) do
            local e = self:element(id)
            if not e then
                break
            end
            e:set_enabled(false)
            end
        end
    end)
end
if RequiredScript == "lib/managers/hudmanager" and Check_Singleplayer() then -- Setup for bot HP being shown.
	local colors = {
		hp_low = Color(1, 0, 0),
		hp_normal = Color(0.5, 0.8, 0.4),
		state_downed = Color(1, 0, 0),
	}

	local HUDManager = module:hook_class("HUDManager")
	module:post_hook(HUDManager, "_add_mugshot", function(self, data, mugshot_data)
		if Network:is_server() then
			mugshot_data.health_background:show()
			mugshot_data.health_health:show()
		end
	end, false)

	module:post_hook(HUDManager, "layout_mugshot_health", function(self, data, amount)
		if not data.peer_id and data.state_name == "mugshot_downed" then
			data.health_health:set_color(colors.state_downed)
		end
	end, false)

	module:post_hook(HUDManager, "set_mugshot_normal", function(self, id)
		local data = self:_get_mugshot_data(id)
		if not data or data.peer_id or not data.health_amount then
			return
		end

		local color = data.health_amount < 0.33 and colors.hp_low or colors.hp_normal
		data.health_health:set_color(color)
	end, false)
end
if RequiredScript == "lib/managers/achievmentmanager" then -- Disable achievements and adds a sandbox check.
    local AchievmentManager = module:hook_class("AchievmentManager")
    module:hook(AchievmentManager, "award_steam", function(self) end)
end
if RequiredScript == "lib/managers/savefilemanager" then -- Creates new save file.
    SavefileManager.PROGRESS_SLOT = 23
end
if RequiredScript == "lib/units/props/christmaspresentbase" and Check_Singleplayer() then -- Spawn christmas present in singleplayer and gives 5k xp when collected.
    function ChristmasPresentBase:init(unit)
        UnitBase.init(self, unit, false)
        self._unit = unit
    end
    
    function ChristmasPresentBase:take_money(unit)
        managers.challenges:set_flag("take_christmas_present")
        managers.experience:add_points(5000, true)
        local params = {}
        params.effect = Idstring("effects/particles/environment/player_snowflakes")
        params.position = Vector3()
        params.rotation = Rotation()
        World:effect_manager():spawn(params)
        managers.hud._sound_source:post_event("jingle_bells")
        Network:detach_unit(self._unit)
        self._unit:set_slot(0)
    end
end
if RequiredScript == "lib/managers/experiencemanager" and Check_Singleplayer() then -- Player no longer heals when they level up, due to how easy it is to grind out levels.
    function ExperienceManager:_level_up()
        local target_tree = managers.upgrades:current_tree()
        managers.upgrades:aquire_target()
        self._global.level = self._global.level + 1
        self:_set_next_level_data(self._global.level + 1)
        local player = managers.player:player_unit()
        --if alive(player) and tweak_data:difficulty_to_index(Global.game_settings.difficulty) < 4 then
            --player:base():replenish()
        --end
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
       -- multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("mr_nice_guy", 1)
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
end
if RequiredScript == "lib/units/beings/player/playerdamage" and Check_Singleplayer() then -- Protector and more blood to bleed crew bonus functions.
    function PlayerDamage:_max_armor()
        if crew_bonus == "protector" or crew_bonus2 == "protector" or crew_bonus3 == "protector" then
            return (self._ARMOR_INIT + managers.player:body_armor_value()) * protector_multi
        else
            return (self._ARMOR_INIT + managers.player:body_armor_value()) * managers.player:synced_crew_bonus_upgrade_value("protector", 1)
        end
    end
    function PlayerDamage:_regenerated()
        self._health = self:_max_health()
        self._revive_health_i = 1
        if crew_bonus == "more_blood_to_bleed" or crew_bonus2 == "more_blood_to_bleed" or crew_bonus3 == "more_blood_to_bleed" then
            self._down_time = tweak_data.player.damage.DOWNED_TIME + 5
        else
            self._down_time = tweak_data.player.damage.DOWNED_TIME + managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 0)
        end
        self._regenerate_timer = nil
        self:_send_set_health()
        self:_set_health_effect()
        self._said_hurt = false
    end
end
if RequiredScript == "lib/tweak_data/upgradestweakdata" and Check_Singleplayer() then -- Changes to upgrades.
    local UpgradesTweakData = module:hook_class("UpgradesTweakData")
    module:post_hook(UpgradesTweakData, "init", function(self)
        self.values.extra_cable_tie.quantity = {4, 8, 12, 16}
        self.values.player.toolset = {0.9, 0.85, 0.8, 0.7}
        self.values.player.extra_ammo_multiplier = {1.1, 1.15, 1.2, 1.25, 1.3}

        self.ammo_bag_base = 5
        self.values.ammo_bag.ammo_increase = {0, 0, 0}
    
        self.doctor_bag_base = 2
        self.values.doctor_bag.amount_increase = {0, 0, 0}
    end, false)
end
if RequiredScript == "lib/tweak_data/weapontweakdata" and Check_Singleplayer() then -- Weapon "rebalances"
    local WeaponTweakData = module:hook_class("WeaponTweakData")
    module:post_hook(WeaponTweakData, "_init_data_player_weapons", function(self)
        if vanilla_weapons then
            return
        end
        -- GL40 --
        -- Less ammo, more damage, explosion range and better ammo pickup.
        self.m79.DAMAGE = 80
        self.m79.EXPLOSION_RANGE = 750
        self.m79.NR_CLIPS_MAX = 2
        self.m79.AMMO_PICKUP = {-3, 1}

        -- Locomotive --
        -- Direct buff, because it sucks in vanilla.
        self.mossberg.DAMAGE = 6
        self.mossberg.AMMO_PICKUP = {1, 1}

        --Mark 11 Ammo, Pickup, RoF & Damage
        self.mac11.AMMO_MAX = 90
        self.mac11.AMMO_PICKUP = {2, 6}
        self.mac11.DAMAGE = 2.4-- from 1.3
        self.mac11.auto.fire_rate = 0.05-- from 0.066 (909) to 0.5 (1200)

        self.beretta92.DAMAGE = 2

        --B9-S Accuracy
        self.beretta92.spread.standing = 2 --from 3.5 (Bonus +42.9% ACC)
        self.beretta92.spread.crouching = 1.4 --from 3.5 (Base +30% ACC)
        self.beretta92.spread.steelsight = 0.8 --from 1.4 (Base +60 ACC)
        self.beretta92.spread.moving_standing = 2 --from 3.5
        self.beretta92.spread.moving_crouching = 2 --from 3.5

        --Crosskill Mag, Ammo, Pickup & Damage
        self.c45.CLIP_AMMO_MAX = 8
        self.c45.AMMO_MAX = 36
        self.c45.AMMO_PICKUP = {1, 1}
        self.c45.DAMAGE = 3.5 --from 1.5

        --Crosskill Accuracy
        self.c45.spread.standing = 3 -- from 4,5 (Bonus +33.3% ACC)
        self.c45.spread.crouching = 2.1 --4,5 (Base +31,1% ACC) (Modded +30% ACC)
        self.c45.spread.steelsight = 1.2 --1,7 (Base +62.2% ACC) (Modded +60% ACC)
        self.c45.spread.moving_standing = 3.5
        self.c45.spread.moving_crouching = 3.5

        --STRKY Ammo, Pickup & Damage
        self.glock.AMMO_MAX = 80 --from 56
        self.glock.AMMO_PICKUP = {1, 4}
        self.glock.DAMAGE = 1.75 --from 1

        --STRKY Accuracy
        self.glock.spread.standing = 3.5 --from 4 (Bonus +12.5% ACC)
        self.glock.spread.crouching = 2.45 --from 4 (Base +30% ACC)
        self.glock.spread.steelsight = 1.4 --from 1.6 (Base +60% ACC)
        self.glock.spread.moving_standing = 3.5 --from 4
        self.glock.spread.moving_crouching = 3.5 --from 4
        
        self.hk21.auto.fire_rate = 0.1

        self.m4.kick.v.steelsight = 0.45 --0.45

        --M308 Ammo & Pickup
        self.m14.AMMO_MAX = 60
        self.m14.AMMO_PICKUP = {1, 4}

        --Compact 5 Ammo, Pickup & Damage
        self.mp5.DAMAGE = 1.6 --from 1.15
        self.mp5.AMMO_MAX = 120
        self.mp5.AMMO_PICKUP = {4, 6}
    end, false)
end
if RequiredScript == "lib/states/missionendstate" and Check_Singleplayer() then -- Solo players can now complete the Noob Lube challenge.
    module:hook(MissionEndState, "at_enter", function(self, old_state, params)
        module:call_orig(MissionEndState, "at_enter", self, old_state, params)
        if self._success and crew_bonus == "noob_lube" and crew_bonus2 == "noob_lube" and crew_bonus3 == "noob_lube" and tweak_data:difficulty_to_index(Global.game_settings.difficulty) >= 4 then
            managers.challenges:set_flag("noob_herder")
        end
     end, false)
end
if RequiredScript == "lib/network/matchmaking/networkmatchmakingsteam" then -- Just in case...
    local NetworkMatchMakingSTEAM = module:hook_class("NetworkMatchMakingSTEAM")

    NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "enhanced_singleplayer"
end
if RequiredScript == "lib/units/beings/player/states/playerstandard" and Check_Singleplayer() then -- Stockholm Syndrome effect.
    local _check_action_primary_attack = PlayerStandard._check_action_primary_attack
    local _StockholmSyndrome = {
        _delay = 0
    }
    
    function PlayerStandard:_check_action_primary_attack(t, input)
        local _res = _check_action_primary_attack(self, t, input)
        if self._shooting and t > _StockholmSyndrome._delay and not managers.groupai:state():whisper_mode() then
            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            _StockholmSyndrome._delay = t + math.random()*3
            --if math.random(1, 3) >= 2 then
                local _local_pos = self._unit:position()
                for u_key, u_data in pairs(managers.enemy:all_civilians()) do
                    if mvector3.distance(u_data.unit:position(), _local_pos) <= 50000000000 then
                        u_data.unit:brain():on_intimidated(1, self._unit)
                    end			
                --end
            end		
        end
        return _res
    end
end
if RequiredScript == "lib/units/props/securitycamera" and Check_Singleplayer() then -- Destroying cameras gives XP and grants solo player the no photos challenge.
    function SecurityCamera:generate_cooldown(amount)
        managers.hint:show_hint("destroyed_security_camera")
        managers.statistics:camera_destroyed()
        managers.experience:add_points(200, true)
        managers.challenges:set_flag("kill_cameras")
    end
end
if RequiredScript == "lib/units/props/securitylockgui" and Check_Singleplayer() then -- Same function as timergui, but with the undercover computer.
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
end
if RequiredScript == "lib/units/beings/player/states/playertased" and Check_Singleplayer() then -- Reduce taser camera shake.
    function PlayerTased:_update_check_actions(t, dt)
        local input = self:_get_input()
        if t > self._next_shock then
            self._next_shock = t + 0.25 + math.rand(1)
            self._unit:camera():play_shaker("player_taser_shock", 0.5, 5)
            self._camera_unit:base():start_shooting()
            self._recoil_t = t + 0
            self._camera_unit:base():recoil_kick(-1, 1) -- Causes the most annoyance for aiming...
            input.btn_primary_attack_state = true
            input.btn_primary_attack_press = true
            self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))
            self._taser_value = math.max(self._taser_value - 0.25, 0)
            self._unit:sound():play("tasered_shock")
            self._unit:camera():play_redirect(self._ids_tased_boost)
            managers.rumble:play("electric_shock")
        elseif self._recoil_t then
            input.btn_primary_attack_state = true
            if t > self._recoil_t then
                self._recoil_t = nil
                self._camera_unit:base():stop_shooting()
            end
    
        end
    
        self._taser_value = math.step(self._taser_value, 0.8, dt / 4)
        managers.environment_controller:set_taser_value(self._taser_value)
        self._shooting = self:_check_action_primary_attack(t, input)
        if self._shooting then
            self._camera_unit:base():recoil_kick(-1, 1) -- also this.
        end
    
        if self._unequip_weapon_expire_t and t >= self._unequip_weapon_expire_t then
            self._unequip_weapon_expire_t = nil
            self:_start_action_equip_weapon(t)
        end
    
        if self._equip_weapon_expire_t and t >= self._equip_weapon_expire_t then
            self._equip_weapon_expire_t = nil
        end
    
        if input.btn_stats_screen_press then
            self._unit:base():set_stats_screen_visible(true)
        elseif input.btn_stats_screen_release then
            self._unit:base():set_stats_screen_visible(false)
        end
    
        self:_update_foley(t, input)
        local new_action
        if not new_action then
        end
    
        self:_check_action_interact(t, input)
        local new_action
        new_action = new_action or self:_check_set_upgrade(t, input)
    end
end
if RequiredScript == "lib/tweak_data/challengestweakdata" then -- Reduce taser camera shake.
    ChallengesTweakData = ChallengesTweakData or class()
    local tiny_xp = 1600
    local small_xp = 2800
    local mid_xp = 4000
    local large_xp = 6200
    local huge_xp = 7400
    local gigantic_xp = 9600
    local ten_steps = {
        "size08",
        "size10",
        "size12",
        "size12",
        "size14",
        "size16",
        "size18",
        "size20",
        "size20",
        "size20"
    }
    local five_steps = {
        "size12",
        "size14",
        "size16",
        "size18",
        "size20"
    }
    function ChallengesTweakData:init()
        self.character = {}
        self.character.bullet_to_bleed_out = {
            title_id = "ch_bullet_to_bleed_out_hl",
            description_id = "ch_bullet_to_bleed_out",
            flag_id = "bullet_to_bleed_out",
            unlock_level = 0,
            xp = tiny_xp,
            in_trial = true
        }
        self.character.fall_to_bleed_out = {
            title_id = "ch_fall_to_bleed_out_hl",
            description_id = "ch_fall_to_bleed_out",
            flag_id = "fall_to_bleed_out",
            unlock_level = 0,
            xp = tiny_xp
        }
        self.character.revived = {
            title_id = "ch_revived_hl",
            description_id = "ch_revived_single",
            counter_id = "revived",
            unlock_level = 0,
            count = 1,
            xp = tiny_xp,
            in_trial = true
        }
        self.character.arrested = {
            title_id = "ch_arrested_hl",
            description_id = "ch_arrested_single",
            counter_id = "arrested",
            unlock_level = 0,
            count = 1,
            xp = tiny_xp,
            in_trial = true
        }
        self.character.deploy_ammobag = {
            title_id = "ch_deploy_ammobag_hl",
            description_id = "ch_deploy_ammobag",
            counter_id = "deploy_ammobag",
            unlock_level = 0,
            count = 10,
            xp = mid_xp,
            depends_on = {
                equipment = {"ammo_bag"}
            }
        }
        self.character.tiedown_civilian = {
            title_id = "ch_tiedown_civilian_hl",
            description_id = "ch_tiedown_civilian",
            counter_id = "tiedown_civilians",
            unlock_level = 0,
            count = 5,
            xp = tiny_xp
        }
        self.character.tiedown_law = {
            title_id = "ch_tiedown_law_hl",
            description_id = "ch_tiedown_law",
            counter_id = "tiedown_law",
            unlock_level = 0,
            count = 5,
            xp = small_xp,
            depends_on = {
                challenges = {
                    "tiedown_civilian"
                }
            }
        }
        self.character.tiedown_cop = {
            title_id = "ch_tiedown_cop_hl",
            description_id = "ch_tiedown_cop",
            counter_id = "tiedown_cop",
            unlock_level = 0,
            count = 5,
            xp = mid_xp,
            depends_on = {
                challenges = {
                    "tiedown_law"
                }
            }
        }
        self.character.tiedown_fbi = {
            title_id = "ch_tiedown_fbi_hl",
            description_id = "ch_tiedown_fbi",
            counter_id = "tiedown_fbi",
            unlock_level = 0,
            count = 5,
            xp = huge_xp,
            depends_on = {
                challenges = {
                    "tiedown_cop"
                }
            }
        }
        self.character.tiedown_swat = {
            title_id = "ch_tiedown_swat_hl",
            description_id = "ch_tiedown_swat",
            counter_id = "tiedown_swat",
            unlock_level = 0,
            count = 5,
            xp = large_xp,
            depends_on = {
                challenges = {
                    "tiedown_fbi"
                }
            }
        }
        self.achievment = {}
        self.achievment.diplomatic = {
            title_id = "ch_diplomatic_hl",
            description_id = "ch_diplomatic",
            flag_id = "diplomatic",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "diplomatic"
        }
        self.achievment.cheney = {
            title_id = "ch_cheney_hl",
            description_id = "ch_cheney",
            flag_id = "cheney",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "cheney"
        }
        self.achievment.intimidating = {
            title_id = "ch_intimidating_hl",
            description_id = "ch_intimidating",
            flag_id = "intimidating",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "intimidating"
        }
        self.achievment.left_for_dead = {
            title_id = "ch_left_for_dead_hl",
            description_id = "ch_left_for_dead",
            flag_id = "left_for_dead",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "left_for_dead"
        }
        self.achievment.blood_in_blood_out = {
            title_id = "ch_blood_in_blood_out_hl",
            description_id = "ch_blood_in_blood_out",
            flag_id = "blood_in_blood_out",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "blood_in_blood_out"
        }
        self.achievment.dodge_this = {
            title_id = "ch_dodge_this_hl",
            description_id = "ch_dodge_this",
            flag_id = "dodge_this",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "dodge_this"
        }
        self.achievment.drop_armored_car = {
            title_id = "ch_drop_armored_car_hl",
            description_id = "ch_drop_armored_car",
            flag_id = "drop_armored_car",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "drop_armored_car"
        }
        self.achievment.last_man_standing = {
            title_id = "ch_last_man_standing_hl",
            description_id = "ch_last_man_standing",
            flag_id = "last_man_standing",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "last_man_standing"
        }
        self.achievment.windowlicker = {
            title_id = "ch_windowlicker_hl",
            description_id = "ch_windowlicker",
            flag_id = "windowlicker",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "windowlicker"
        }
        self.achievment.civil_disobedience = {
            title_id = "ch_civil_disobedience_hl",
            description_id = "ch_civil_disobedience",
            flag_id = "civil_disobedience",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "civil_disobedience"
        }
        self.achievment.take_money = {
            title_id = "ch_take_money_hl",
            description_id = "ch_take_money",
            flag_id = "take_money",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "take_money"
        }
        self.achievment.the_darkness = {
            title_id = "ch_the_darkness_hl",
            description_id = "ch_the_darkness",
            flag_id = "the_darkness",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "the_darkness"
        }
        self.achievment.chavez_can_run = {
            title_id = "ch_chavez_can_run_hl",
            description_id = "ch_chavez_can_run",
            flag_id = "chavez_can_run",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "chavez_can_run"
        }
        self.achievment.ninja = {
            title_id = "ch_ninja_hl",
            description_id = "ch_ninja",
            flag_id = "ninja",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "ninja"
        }
        self.achievment.take_sapphires = {
            title_id = "ch_take_sapphires_hl",
            description_id = "ch_take_sapphires",
            flag_id = "take_sapphires",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "take_sapphires"
        }
        self.achievment.quick_gold = {
            title_id = "ch_quick_gold_hl",
            description_id = "ch_quick_gold",
            flag_id = "quick_gold",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "quick_gold"
        }
        self.achievment.stand_together = {
            title_id = "ch_stand_together_hl",
            description_id = "ch_stand_together",
            flag_id = "stand_together",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "stand_together"
        }
        self.achievment.kill_thugs = {
            title_id = "ch_kill_thugs_hl",
            description_id = "ch_kill_thugs",
            flag_id = "kill_thugs",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "kill_thugs"
        }
        self.achievment.kill_cameras = {
            title_id = "ch_kill_cameras_hl",
            description_id = "ch_kill_cameras",
            flag_id = "kill_cameras",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "kill_cameras"
        }
        self.achievment.hot_lava = {
            title_id = "ch_hot_lava_hl",
            description_id = "ch_hot_lava",
            flag_id = "hot_lava",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "hot_lava"
        }
        self.achievment.federal_crime = {
            title_id = "ch_federal_crime_hl",
            description_id = "ch_federal_crime",
            flag_id = "federal_crime",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "federal_crime"
        }
        self.achievment.one_shot_one_kill = {
            title_id = "ch_one_shot_one_kill_hl",
            description_id = "ch_one_shot_one_kill",
            flag_id = "one_shot_one_kill",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "one_shot_one_kill"
        }
        self.achievment.bomb_man = {
            title_id = "ch_bomb_man_hl",
            description_id = "ch_bomb_man",
            flag_id = "bomb_man",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "bomb_man"
        }
        self.achievment.duck_hunting = {
            title_id = "ch_duck_hunting_hl",
            description_id = "ch_duck_hunting",
            flag_id = "duck_hunting",
            unlock_level = 0,
            xp = small_xp,
            awards_achievment = "duck_hunting"
        }
        self.achievment.ready_yet = {
            title_id = "ch_ready_yet_hl",
            description_id = "ch_ready_yet",
            flag_id = "ready_yet",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "ready_yet"
        }
        self.achievment.cant_touch = {
            title_id = "ch_cant_touch_hl",
            description_id = "ch_cant_touch",
            flag_id = "cant_touch",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "cant_touch"
        }
        self.achievment.dozen_angry = {
            title_id = "ch_dozen_angry_hl",
            description_id = "ch_dozen_angry",
            flag_id = "dozen_angry",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "dozen_angry"
        }
        self.achievment.noob_herder = {
            title_id = "ch_noob_herder_hl",
            description_id = "ch_noob_herder",
            flag_id = "noob_herder",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "noob_herder"
        }
        self.achievment.dont_lose = {
            title_id = "ch_dont_lose_face_hl",
            description_id = "ch_dont_lose_face",
            counter_id = "dont_lose_face",
            count = 6,
            unlock_level = 48,
            xp = gigantic_xp,
            awards_achievment = "dont_lose_face"
        }
        self.achievment.eagle_eyes = {
            title_id = "ch_eagle_eyes_hl",
            description_id = "ch_eagle_eyes",
            flag_id = "eagle_eyes",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "eagle_eyes"
        }
        self.achievment.aint_afraid = {
            title_id = "ch_aint_afraid_hl",
            description_id = "ch_aint_afraid",
            flag_id = "aint_afraid",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "aint_afraid"
        }
        self.achievment.crack_bang = {
            title_id = "ch_crack_bang_hl",
            description_id = "ch_crack_bang",
            flag_id = "crack_bang",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "crack_bang"
        }
        self.achievment.lay_on_hands = {
            title_id = "ch_lay_on_hands_hl",
            description_id = "ch_lay_on_hands",
            flag_id = "lay_on_hands",
            unlock_level = 0,
            xp = mid_xp,
            awards_achievment = "lay_on_hands"
        }
        self.achievment.christmas_present = {
            title_id = "ch_christmas_present_hl",
            description_id = "ch_christmas_present",
            flag_id = "take_christmas_present",
            unlock_level = 0,
            xp = large_xp,
            awards_achievment = "christmas_present"
        }
        self.achievment.golden_boy = {
            title_id = "ch_golden_boy_hl",
            description_id = "ch_golden_boy",
            counter_id = "golden_boy",
            count = 6,
            unlock_level = 145,
            xp = gigantic_xp,
            awards_achievment = "golden_boy"
        }
        self.achievment.president = {
            title_id = "ch_president_hl",
            description_id = "ch_president",
            flag_id = "president",
            unlock_level = 0,
            xp = gigantic_xp,
            awards_achievment = "president"
        }
        self.achievment.tester = {
            title_id = "ch_tester_hl",
            description_id = "ch_tester",
            flag_id = "tester",
            unlock_level = 0,
            xp = tiny_xp,
            awards_achievment = "tester"
        }
        if managers.dlc:has_dlc1() then
            self.achievment.crowd_control = {
                title_id = "ch_crowd_control_hl",
                description_id = "ch_crowd_control",
                flag_id = "crowd_control",
                unlock_level = 0,
                xp = tiny_xp,
                awards_achievment = "crowd_control"
            }
            self.achievment.quick_hands = {
                title_id = "ch_quick_hands_hl",
                description_id = "ch_quick_hands",
                flag_id = "quick_hands",
                unlock_level = 0,
                xp = tiny_xp,
                awards_achievment = "quick_hands"
            }
            self.achievment.pacifist = {
                title_id = "ch_pacifist_hl",
                description_id = "ch_pacifist",
                flag_id = "pacifist",
                unlock_level = 0,
                xp = gigantic_xp,
                awards_achievment = "pacifist"
            }
            self.achievment.blow_out = {
                title_id = "ch_blow_out_hl",
                description_id = "ch_blow_out",
                flag_id = "blow_out",
                unlock_level = 0,
                xp = mid_xp,
                awards_achievment = "blow_out"
            }
            self.achievment.saviour = {
                title_id = "ch_saviour_hl",
                description_id = "ch_saviour",
                flag_id = "saviour",
                unlock_level = 0,
                xp = tiny_xp,
                awards_achievment = "saviour"
            }
            self.achievment.det_gadget = {
                title_id = "ch_det_gadget_hl",
                description_id = "ch_det_gadget",
                flag_id = "det_gadget",
                unlock_level = 0,
                xp = tiny_xp,
                awards_achievment = "det_gadget"
            }
        end
        if managers.dlc:has_dlc4() then
            self.achievment.dont_panic = {
                title_id = "ch_hos_dont_panic_hl",
                description_id = "ch_hos_dont_panic",
                flag_id = "dont_panic",
                unlock_level = 0,
                xp = tiny_xp,
                awards_achievment = "dont_panic"
            }
            self.achievment.cut_wire = {
                title_id = "ch_hos_cut_wire_hl",
                description_id = "ch_hos_cut_wire",
                flag_id = "cut_wire",
                unlock_level = 0,
                xp = mid_xp,
                awards_achievment = "cut_wire"
            }
            self.achievment.wrong_door = {
                title_id = "ch_hos_wrong_door_hl",
                description_id = "ch_hos_wrong_door",
                flag_id = "wrong_door",
                unlock_level = 0,
                xp = large_xp,
                awards_achievment = "wrong_door"
            }
            self.achievment.afraid_of_the_dark = {
                title_id = "ch_hos_afraid_of_the_dark_hl",
                description_id = "ch_hos_afraid_of_the_dark",
                flag_id = "afraid_of_the_dark",
                unlock_level = 0,
                xp = mid_xp,
                awards_achievment = "afraid_of_the_dark"
            }
        end
        self.weapon = {}
        self:_any_weapon_challenges()
        self:_c45_challenges()
        self:_beretta92_challenges()
        self:_bronco_challenges()
        self:_reinbeck_challenges()
        self:_mossberg_challenges()
        self:_mp5_challenges()
        self:_mac11_challenges()
        self:_m4_challenges()
        self:_m14_challenges()
        self:_hk21_challenges()
        if managers.dlc:has_dlc1() then
            self:_glock_challenges()
            self:_ak47_challenges()
            self:_m79_challenges()
            self:_sentry_gun_challenges()
        end
        self:_melee_challenges()
        self:_bleed_out_challenges()
        self:_trip_mine_challenges()
        self.character.revive_1 = {
            title_id = "ch_revive_1_hl",
            description_id = "ch_revive",
            counter_id = "revive",
            unlock_level = 0,
            count = 5,
            xp = tiny_xp,
            in_trial = true
        }
        self.character.revive_2 = {
            title_id = "ch_revive_2_hl",
            description_id = "ch_revive",
            counter_id = "revive",
            unlock_level = 0,
            count = 10,
            xp = small_xp,
            depends_on = {
                challenges = {"revive_1"}
            }
        }
        self.character.revive_3 = {
            title_id = "ch_revive_3_hl",
            description_id = "ch_revive",
            counter_id = "revive",
            unlock_level = 0,
            count = 15,
            xp = mid_xp,
            depends_on = {
                challenges = {"revive_2"}
            }
        }
        self.character.revive_4 = {
            title_id = "ch_revive_4_hl",
            description_id = "ch_revive",
            counter_id = "revive",
            unlock_level = 0,
            count = 20,
            xp = large_xp,
            depends_on = {
                challenges = {"revive_3"}
            }
        }
        self.session = {}
        self:_money_challenges()
        self.session.bank_no_civilians_hard = {
            title_id = "ch_bank_no_civilians_hl",
            description_id = "ch_bank_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "bank",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.bank_no_deaths_hard = {
            title_id = "ch_bank_no_deaths_hl",
            description_id = "ch_bank_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "bank",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.bank_no_bleedouts_hard = {
            title_id = "ch_bank_no_bleedouts_hl",
            description_id = "ch_bank_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "bank",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.bank_success_overkill = {
            title_id = "ch_bank_on_overkill_hl",
            description_id = "ch_bank_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "bank",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.bank_overkill_no_trade = {
            title_id = "ch_bank_overkill_no_trade_hl",
            description_id = "ch_bank_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "bank",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.bank_success_overkill_145 = {
            title_id = "ch_bank_on_overkill_145_hl",
            description_id = "ch_bank_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            level_id = "bank",
            difficulty = "overkill_145",
            increment_counter = "golden_boy",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "bank_145"
        }
        self.session.street_no_civilians_hard = {
            title_id = "ch_street_no_civilians_hl",
            description_id = "ch_street_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "heat_street",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.street_no_deaths_hard = {
            title_id = "ch_street_no_deaths_hl",
            description_id = "ch_street_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "heat_street",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.street_no_bleedouts_hard = {
            title_id = "ch_street_no_bleedouts_hl",
            description_id = "ch_street_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "heat_street",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.street_success_overkill = {
            title_id = "ch_street_on_overkill_hl",
            description_id = "ch_street_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "heat_street",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.street_overkill_no_trade = {
            title_id = "ch_street_overkill_no_trade_hl",
            description_id = "ch_street_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "heat_street",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.street_success_overkill_145 = {
            title_id = "ch_street_on_overkill_145_hl",
            description_id = "ch_street_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            increment_counter = "golden_boy",
            level_id = "heat_street",
            difficulty = "overkill_145",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "street_145"
        }
        self.session.bridge_no_civilians_hard = {
            title_id = "ch_bridge_no_civilians_hl",
            description_id = "ch_bridge_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "bridge",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.bridge_no_deaths_hard = {
            title_id = "ch_bridge_no_deaths_hl",
            description_id = "ch_bridge_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "bridge",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.bridge_no_bleedouts_hard = {
            title_id = "ch_bridge_no_bleedouts_hl",
            description_id = "ch_bridge_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "bridge",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.bridge_success_overkill = {
            title_id = "ch_bridge_on_overkill_hl",
            description_id = "ch_bridge_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "bridge",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.bridge_overkill_no_trade = {
            title_id = "ch_bridge_overkill_no_trade_hl",
            description_id = "ch_bridge_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "bridge",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.bridge_success_overkill_145 = {
            title_id = "ch_bridge_on_overkill_145_hl",
            description_id = "ch_bridge_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            increment_counter = "golden_boy",
            level_id = "bridge",
            difficulty = "overkill_145",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "bridge_145"
        }
        self.session.apartment_no_civilians_hard = {
            title_id = "ch_apartment_no_civilians_hl",
            description_id = "ch_apartment_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "apartment",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.apartment_no_deaths_hard = {
            title_id = "ch_apartment_no_deaths_hl",
            description_id = "ch_apartment_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "apartment",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.apartment_no_bleedouts_hard = {
            title_id = "ch_apartment_no_bleedouts_hl",
            description_id = "ch_apartment_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "apartment",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.apartment_success_overkill = {
            title_id = "ch_apartment_on_overkill_hl",
            description_id = "ch_apartment_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "apartment",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.apartment_overkill_no_trade = {
            title_id = "ch_apartment_overkill_no_trade_hl",
            description_id = "ch_apartment_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "apartment",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.apartment_success_overkill_145 = {
            title_id = "ch_apartment_on_overkill_145_hl",
            description_id = "ch_apartment_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            increment_counter = "golden_boy",
            level_id = "apartment",
            difficulty = "overkill_145",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "apartment_145"
        }
        self.session.slaughterhouse_no_civilians_hard = {
            title_id = "ch_slaughterhouse_no_civilians_hl",
            description_id = "ch_slaughterhouse_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "slaughter_house",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.slaughterhouse_no_deaths_hard = {
            title_id = "ch_slaughterhouse_no_deaths_hl",
            description_id = "ch_slaughterhouse_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "slaughter_house",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.slaughterhouse_no_bleedouts_hard = {
            title_id = "ch_slaughterhouse_no_bleedouts_hl",
            description_id = "ch_slaughterhouse_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "slaughter_house",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.slaughterhouse_success_overkill = {
            title_id = "ch_slaughterhouse_on_overkill_hl",
            description_id = "ch_slaughterhouse_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "slaughter_house",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.slaughterhouse_overkill_no_trade = {
            title_id = "ch_slaughterhouse_overkill_no_trade_hl",
            description_id = "ch_slaughterhouse_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "slaughter_house",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.slaughterhouse_success_overkill_145 = {
            title_id = "ch_slaughterhouse_on_overkill_145_hl",
            description_id = "ch_slaughterhouse_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            increment_counter = "golden_boy",
            level_id = "slaughter_house",
            difficulty = "overkill_145",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "slaughter_house_145"
        }
        self.session.diamond_heist_no_civilians_hard = {
            title_id = "ch_diamond_heist_no_civilians_hl",
            description_id = "ch_diamond_heist_no_civilians",
            unlock_level = 20,
            xp = mid_xp,
            level_id = "diamond_heist",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "no_civilians_killed"
            }
        }
        self.session.diamond_heist_no_deaths_hard = {
            title_id = "ch_diamond_heist_no_deaths_hl",
            description_id = "ch_diamond_heist_no_deaths",
            unlock_level = 20,
            xp = large_xp,
            level_id = "diamond_heist",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {callback = "never_died"}
        }
        self.session.diamond_heist_no_bleedouts_hard = {
            title_id = "ch_diamond_heist_no_bleedouts_hl",
            description_id = "ch_diamond_heist_no_bleedouts",
            unlock_level = 20,
            xp = huge_xp,
            level_id = "diamond_heist",
            difficulty = {
                "hard",
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "never_bleedout"
            }
        }
        self.session.diamond_heist_success_overkill = {
            title_id = "ch_diamond_heist_on_overkill_hl",
            description_id = "ch_diamond_heist_on_overkill",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "diamond_heist",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            session_stopped = {
                callback = "overkill_success"
            }
        }
        self.session.diamond_heist_overkill_no_trade = {
            title_id = "ch_diamond_heist_overkill_no_trade_hl",
            description_id = "ch_diamond_heist_overkill_no_trade",
            unlock_level = 48,
            xp = gigantic_xp,
            level_id = "diamond_heist",
            difficulty = {
                "overkill",
                "overkill_145"
            },
            increment_counter = "dont_lose_face",
            session_stopped = {
                callback = "overkill_no_trade"
            }
        }
        self.session.diamond_heist_success_overkill_145 = {
            title_id = "ch_diamond_heist_on_overkill_145_hl",
            description_id = "ch_diamond_heist_on_overkill_145",
            unlock_level = 145,
            xp = gigantic_xp,
            increment_counter = "golden_boy",
            level_id = "diamond_heist",
            difficulty = "overkill_145",
            session_stopped = {
                callback = "overkill_success"
            },
            awards_achievment = "diamond_heist_145"
        }
        if managers.dlc:has_dlc2() then
            self.session.suburbia_no_civilians_hard = {
                title_id = "ch_suburbia_no_civilians_hl",
                description_id = "ch_suburbia_no_civilians",
                unlock_level = 20,
                xp = mid_xp,
                level_id = "suburbia",
                difficulty = {
                    "hard",
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "no_civilians_killed"
                }
            }
            self.session.suburbia_no_deaths_hard = {
                title_id = "ch_suburbia_no_deaths_hl",
                description_id = "ch_suburbia_no_deaths",
                unlock_level = 20,
                xp = large_xp,
                level_id = "suburbia",
                difficulty = {
                    "hard",
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {callback = "never_died"}
            }
            self.session.suburbia_no_bleedouts_hard = {
                title_id = "ch_suburbia_no_bleedouts_hl",
                description_id = "ch_suburbia_no_bleedouts",
                unlock_level = 20,
                xp = huge_xp,
                level_id = "suburbia",
                difficulty = {
                    "hard",
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "never_bleedout"
                }
            }
            self.session.suburbia_success_overkill = {
                title_id = "ch_suburbia_on_overkill_hl",
                description_id = "ch_suburbia_on_overkill",
                unlock_level = 48,
                xp = gigantic_xp,
                level_id = "suburbia",
                difficulty = {
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "overkill_success"
                }
            }
            self.session.suburbia_overkill_no_trade = {
                title_id = "ch_suburbia_overkill_no_trade_hl",
                description_id = "ch_suburbia_overkill_no_trade",
                unlock_level = 48,
                xp = gigantic_xp,
                level_id = "suburbia",
                difficulty = {
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "overkill_no_trade"
                }
            }
            self.session.suburbia_success_overkill_145 = {
                title_id = "ch_suburbia_on_overkill_145_hl",
                description_id = "ch_suburbia_on_overkill_145",
                unlock_level = 145,
                xp = gigantic_xp,
                level_id = "suburbia",
                difficulty = "overkill_145",
                session_stopped = {
                    callback = "overkill_success"
                },
                awards_achievment = "suburbia_145"
            }
        end
        if managers.dlc:has_dlc3() then
            self.session.secret_stash_no_deaths_hard = {
                title_id = "ch_secret_stash_no_deaths_hl",
                description_id = "ch_secret_stash_no_deaths",
                unlock_level = 20,
                xp = large_xp,
                level_id = "secret_stash",
                difficulty = {
                    "hard",
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {callback = "never_died"}
            }
            self.session.secret_stash_no_bleedouts_hard = {
                title_id = "ch_secret_stash_no_bleedouts_hl",
                description_id = "ch_secret_stash_no_bleedouts",
                unlock_level = 20,
                xp = huge_xp,
                level_id = "secret_stash",
                difficulty = {
                    "hard",
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "never_bleedout"
                }
            }
            self.session.secret_stash_success_overkill = {
                title_id = "ch_secret_stash_on_overkill_hl",
                description_id = "ch_secret_stash_on_overkill",
                unlock_level = 48,
                xp = gigantic_xp,
                level_id = "secret_stash",
                difficulty = {
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "overkill_success"
                }
            }
            self.session.secret_stash_overkill_no_trade = {
                title_id = "ch_secret_stash_overkill_no_trade_hl",
                description_id = "ch_secret_stash_overkill_no_trade",
                unlock_level = 48,
                xp = gigantic_xp,
                level_id = "secret_stash",
                difficulty = {
                    "overkill",
                    "overkill_145"
                },
                session_stopped = {
                    callback = "overkill_no_trade"
                }
            }
            self.session.secret_stash_success_overkill_145 = {
                title_id = "ch_secret_stash_on_overkill_145_hl",
                description_id = "ch_secret_stash_on_overkill_145",
                unlock_level = 145,
                xp = gigantic_xp,
                level_id = "secret_stash",
                difficulty = "overkill_145",
                session_stopped = {
                    callback = "overkill_success"
                },
                awards_achievment = "secret_stash_145"
            }
        end
    end
    function ChallengesTweakData:_any_weapon_challenges()
        local definition = {}
        definition.me = {}
        definition.me.vs_the_law = {
            {
                count = 50,
                xp = tiny_xp,
                in_trial = true
            },
            {count = 100, xp = small_xp},
            {count = 150, xp = mid_xp}
        }
        definition.me.vs_the_law_head_shot = {
            {count = 50, xp = tiny_xp},
            {count = 100, xp = small_xp},
            {count = 150, xp = mid_xp},
            {count = 200, xp = large_xp},
            {count = 250, xp = huge_xp}
        }
        for i = 1, #definition.me.vs_the_law do
            local name = "me_vs_the_law_" .. i
            local count = definition.me.vs_the_law[i].count
            local xp = definition.me.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "me_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_me_vs_the_law_" .. i .. "_hl",
                description_id = "ch_me_vs_the_law",
                counter_id = "law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on,
                in_trial = definition.me.vs_the_law[i].in_trial
            }
        end
        for i = 1, #definition.me.vs_the_law_head_shot do
            local name = "me_vs_the_law_head_shot_" .. i
            local count = definition.me.vs_the_law_head_shot[i].count
            local xp = definition.me.vs_the_law_head_shot[i].xp
            local challenges = {
                i - 1 > 0 and "me_vs_the_law_head_shot_" .. i - 1 or "me_vs_the_law_2"
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_me_vs_the_law_head_shot_" .. i .. "_hl",
                description_id = "ch_me_vs_the_law_head_shot",
                counter_id = "law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on,
                in_trial = definition.me.vs_the_law_head_shot[i].in_trial
            }
        end
        self.weapon.me_vs_cop = {
            title_id = "ch_me_vs_cop_hl",
            description_id = "ch_me_vs_cop",
            counter_id = "cop_kill",
            unlock_level = 0,
            count = 25,
            xp = mid_xp,
            depends_on = {
                challenges = {
                    "me_vs_the_law_3"
                }
            }
        }
        self.weapon.me_vs_swat = {
            title_id = "ch_me_vs_swat_hl",
            description_id = "ch_me_vs_swat",
            counter_id = "swat_kill",
            unlock_level = 0,
            count = 25,
            xp = mid_xp,
            depends_on = {
                challenges = {"me_vs_cop"}
            }
        }
        self.weapon.me_vs_fbi = {
            title_id = "ch_me_vs_fbi_hl",
            description_id = "ch_me_vs_fbi",
            counter_id = "fbi_kill",
            unlock_level = 0,
            count = 25,
            xp = mid_xp,
            depends_on = {
                challenges = {"me_vs_swat"}
            }
        }
        self.weapon.me_vs_heavy_swat = {
            title_id = "ch_me_vs_heavy_swat_hl",
            description_id = "ch_me_vs_heavy_swat",
            counter_id = "heavy_swat_kill",
            unlock_level = 0,
            count = 50,
            xp = large_xp,
            depends_on = {
                challenges = {"me_vs_fbi"}
            }
        }
        self.weapon.me_vs_shield = {
            title_id = "ch_me_vs_shield_hl",
            description_id = "ch_me_vs_shield",
            counter_id = "shield_kill",
            unlock_level = 0,
            count = 5,
            xp = huge_xp,
            depends_on = {
                challenges = {
                    "me_vs_heavy_swat"
                }
            }
        }
        self.weapon.me_vs_taser = {
            title_id = "ch_me_vs_taser_hl",
            description_id = "ch_me_vs_taser",
            counter_id = "taser_kill",
            unlock_level = 0,
            count = 5,
            xp = gigantic_xp,
            depends_on = {
                challenges = {
                    "me_vs_shield"
                }
            }
        }
        self.weapon.me_vs_spooc = {
            title_id = "ch_me_vs_spooc_hl",
            description_id = "ch_me_vs_spooc",
            counter_id = "spooc_kill",
            unlock_level = 0,
            count = 5,
            xp = gigantic_xp,
            depends_on = {
                challenges = {
                    "me_vs_taser"
                }
            }
        }
        self.weapon.me_vs_tank = {
            title_id = "ch_me_vs_tank_hl",
            description_id = "ch_me_vs_tank",
            counter_id = "tank_kill",
            unlock_level = 0,
            count = 5,
            xp = gigantic_xp,
            depends_on = {
                challenges = {
                    "me_vs_spooc"
                }
            }
        }
    end
    function ChallengesTweakData:_c45_challenges()
        local definition = {}
        definition.c45 = {}
        definition.c45.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.c45.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.c45.fbi_kill = {
            {count = 10, xp = huge_xp}
        }
        for i = 1, #definition.c45.vs_the_law do
            local name = "c45_vs_the_law_" .. i
            local count = definition.c45.vs_the_law[i].count
            local xp = definition.c45.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "c45_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"c45"}
            }
            self.weapon[name] = {
                title_id = "ch_c45_vs_the_law_" .. i .. "_hl",
                description_id = "ch_c45_vs_the_law",
                counter_id = "c45_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.c45.head_shots do
            local name = "c45_head_shots_" .. i
            local count = definition.c45.head_shots[i].count
            local xp = definition.c45.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "c45_head_shots_" .. i - 1 or "c45_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"c45"}
            }
            self.weapon[name] = {
                title_id = "ch_c45_head_shots_" .. i .. "_hl",
                description_id = "ch_c45_head_shots",
                counter_id = "c45_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.c45.fbi_kill do
            local name = "c45_fbi_kill_" .. i
            local count = definition.c45.fbi_kill[i].count
            local xp = definition.c45.fbi_kill[i].xp
            local challenges = {
                i - 1 > 0 and "c45_fbi_kill" .. i - 1 or "c45_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"c45"}
            }
            self.weapon[name] = {
                title_id = "ch_c45_fbi_kill_" .. i .. "_hl",
                description_id = "ch_c45_fbi_kill",
                counter_id = "c45_fbi_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_beretta92_challenges()
        local definition = {}
        definition.beretta92 = {}
        definition.beretta92.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.beretta92.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.beretta92.taser_kill = {
            {count = 3, xp = huge_xp}
        }
        for i = 1, #definition.beretta92.vs_the_law do
            local name = "beretta92_vs_the_law_" .. i
            local count = definition.beretta92.vs_the_law[i].count
            local xp = definition.beretta92.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "beretta92_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_beretta92_vs_the_law_" .. i .. "_hl",
                description_id = "ch_beretta92_vs_the_law",
                counter_id = "beretta92_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.beretta92.head_shots do
            local name = "beretta92_head_shots_" .. i
            local count = definition.beretta92.head_shots[i].count
            local xp = definition.beretta92.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "beretta92_head_shots_" .. i - 1 or "beretta92_vs_the_law_3"
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_beretta92_head_shots_" .. i .. "_hl",
                description_id = "ch_beretta92_head_shots",
                counter_id = "beretta92_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.beretta92.taser_kill do
            local name = "beretta92_taser_kill_" .. i
            local count = definition.beretta92.taser_kill[i].count
            local xp = definition.beretta92.taser_kill[i].xp
            local challenges = {
                i - 1 > 0 and "beretta92_taser_kill" .. i - 1 or "beretta92_vs_the_law_5"
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_beretta92_taser_kill_" .. i .. "_hl",
                description_id = "ch_beretta92_taser_kill",
                counter_id = "beretta92_taser_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_bronco_challenges()
        local definition = {}
        definition.bronco = {}
        definition.bronco.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.bronco.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.bronco.tank_kill = {
            {count = 3, xp = huge_xp}
        }
        for i = 1, #definition.bronco.vs_the_law do
            local name = "bronco_vs_the_law_" .. i
            local count = definition.bronco.vs_the_law[i].count
            local xp = definition.bronco.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "bronco_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "raging_bull"
                }
            }
            self.weapon[name] = {
                title_id = "ch_bronco_vs_the_law_" .. i .. "_hl",
                description_id = "ch_bronco_vs_the_law",
                counter_id = "bronco_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.bronco.head_shots do
            local name = "bronco_head_shots_" .. i
            local count = definition.bronco.head_shots[i].count
            local xp = definition.bronco.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "bronco_head_shots_" .. i - 1 or "bronco_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "raging_bull"
                }
            }
            self.weapon[name] = {
                title_id = "ch_bronco_head_shots_" .. i .. "_hl",
                description_id = "ch_bronco_head_shots",
                counter_id = "bronco_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.bronco.tank_kill do
            local name = "bronco_tank_kill_" .. i
            local count = definition.bronco.tank_kill[i].count
            local xp = definition.bronco.tank_kill[i].xp
            local challenges = {
                i - 1 > 0 and "bronco_tank_kill" .. i - 1 or "bronco_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "raging_bull"
                }
            }
            self.weapon[name] = {
                title_id = "ch_bronco_tank_kill_" .. i .. "_hl",
                description_id = "ch_bronco_tank_kill",
                counter_id = "bronco_tank_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_reinbeck_challenges()
        local definition = {}
        definition.reinbeck = {}
        definition.reinbeck.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.reinbeck.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.reinbeck.spooc_kill = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.reinbeck.vs_the_law do
            local name = "reinbeck_vs_the_law_" .. i
            local count = definition.reinbeck.vs_the_law[i].count
            local xp = definition.reinbeck.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "reinbeck_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "r870_shotgun"
                }
            }
            self.weapon[name] = {
                title_id = "ch_reinbeck_vs_the_law_" .. i .. "_hl",
                description_id = "ch_reinbeck_vs_the_law",
                counter_id = "reinbeck_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.reinbeck.head_shots do
            local name = "reinbeck_head_shots_" .. i
            local count = definition.reinbeck.head_shots[i].count
            local xp = definition.reinbeck.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "reinbeck_head_shots_" .. i - 1 or "reinbeck_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "r870_shotgun"
                }
            }
            self.weapon[name] = {
                title_id = "ch_reinbeck_head_shots_" .. i .. "_hl",
                description_id = "ch_reinbeck_head_shots",
                counter_id = "reinbeck_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.reinbeck.spooc_kill do
            local name = "reinbeck_spooc_kill_" .. i
            local count = definition.reinbeck.spooc_kill[i].count
            local xp = definition.reinbeck.spooc_kill[i].xp
            local challenges = {
                i - 1 > 0 and "reinbeck_spooc_kill" .. i - 1 or "reinbeck_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {
                    "r870_shotgun"
                }
            }
            self.weapon[name] = {
                title_id = "ch_reinbeck_spooc_kill_" .. i .. "_hl",
                description_id = "ch_reinbeck_spooc_kill",
                counter_id = "reinbeck_spooc_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_mossberg_challenges()
        local definition = {}
        definition.mossberg = {}
        definition.mossberg.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.mossberg.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.mossberg.cop_kill = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.mossberg.vs_the_law do
            local name = "mossberg_vs_the_law_" .. i
            local count = definition.mossberg.vs_the_law[i].count
            local xp = definition.mossberg.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "mossberg_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mossberg"}
            }
            self.weapon[name] = {
                title_id = "ch_mossberg_vs_the_law_" .. i .. "_hl",
                description_id = "ch_mossberg_vs_the_law",
                counter_id = "mossberg_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mossberg.head_shots do
            local name = "mossberg_head_shots_" .. i
            local count = definition.mossberg.head_shots[i].count
            local xp = definition.mossberg.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "mossberg_head_shots_" .. i - 1 or "mossberg_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mossberg"}
            }
            self.weapon[name] = {
                title_id = "ch_mossberg_head_shots_" .. i .. "_hl",
                description_id = "ch_mossberg_head_shots",
                counter_id = "mossberg_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mossberg.cop_kill do
            local name = "mossberg_cop_kill_" .. i
            local count = definition.mossberg.cop_kill[i].count
            local xp = definition.mossberg.cop_kill[i].xp
            local challenges = {
                i - 1 > 0 and "mossberg_cop_kill" .. i - 1 or "mossberg_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mossberg"}
            }
            self.weapon[name] = {
                title_id = "ch_mossberg_cop_kill_" .. i .. "_hl",
                description_id = "ch_mossberg_cop_kill",
                counter_id = "mossberg_cop_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_mp5_challenges()
        local definition = {}
        definition.mp5 = {}
        definition.mp5.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.mp5.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.mp5.shield_head_shots = {
            {count = 3, xp = huge_xp}
        }
        for i = 1, #definition.mp5.vs_the_law do
            local name = "mp5_vs_the_law_" .. i
            local count = definition.mp5.vs_the_law[i].count
            local xp = definition.mp5.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "mp5_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mp5"}
            }
            self.weapon[name] = {
                title_id = "ch_mp5_vs_the_law_" .. i .. "_hl",
                description_id = "ch_mp5_vs_the_law",
                counter_id = "mp5_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mp5.head_shots do
            local name = "mp5_head_shots_" .. i
            local count = definition.mp5.head_shots[i].count
            local xp = definition.mp5.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "mp5_head_shots_" .. i - 1 or "mp5_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mp5"}
            }
            self.weapon[name] = {
                title_id = "ch_mp5_head_shots_" .. i .. "_hl",
                description_id = "ch_mp5_head_shots",
                counter_id = "mp5_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mp5.shield_head_shots do
            local name = "mp5_shield_head_shots_" .. i
            local count = definition.mp5.shield_head_shots[i].count
            local xp = definition.mp5.shield_head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "mp5_shield_head_shots" .. i - 1 or "mp5_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mp5"}
            }
            self.weapon[name] = {
                title_id = "ch_mp5_shield_head_shot_" .. i .. "_hl",
                description_id = "ch_mp5_shield_head_shot",
                counter_id = "mp5_shield_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_mac11_challenges()
        local definition = {}
        definition.mac11 = {}
        definition.mac11.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.mac11.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.mac11.heavy_swat_kill = {
            {count = 25, xp = huge_xp}
        }
        for i = 1, #definition.mac11.vs_the_law do
            local name = "mac11_vs_the_law_" .. i
            local count = definition.mac11.vs_the_law[i].count
            local xp = definition.mac11.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "mac11_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mac11"}
            }
            self.weapon[name] = {
                title_id = "ch_mac11_vs_the_law_" .. i .. "_hl",
                description_id = "ch_mac11_vs_the_law",
                counter_id = "mac11_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mac11.head_shots do
            local name = "mac11_head_shots_" .. i
            local count = definition.mac11.head_shots[i].count
            local xp = definition.mac11.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "mac11_head_shots_" .. i - 1 or "mac11_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mac11"}
            }
            self.weapon[name] = {
                title_id = "ch_mac11_head_shots_" .. i .. "_hl",
                description_id = "ch_mac11_head_shots",
                counter_id = "mac11_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.mac11.heavy_swat_kill do
            local name = "mac11_heavy_swat_kill_" .. i
            local count = definition.mac11.heavy_swat_kill[i].count
            local xp = definition.mac11.heavy_swat_kill[i].xp
            local challenges = {
                i - 1 > 0 and "mac11_heavy_swat_kill" .. i - 1 or "mac11_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"mac11"}
            }
            self.weapon[name] = {
                title_id = "ch_mac11_heavy_swat_kill_" .. i .. "_hl",
                description_id = "ch_mac11_heavy_swat_kill",
                counter_id = "mac11_heavy_swat_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_m4_challenges()
        local definition = {}
        definition.m4 = {}
        definition.m4.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.m4.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.m4.spooc_head_shot = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.m4.vs_the_law do
            local name = "m4_vs_the_law_" .. i
            local count = definition.m4.vs_the_law[i].count
            local xp = definition.m4.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "m4_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges, weapons = nil}
            self.weapon[name] = {
                title_id = "ch_m4_vs_the_law_" .. i .. "_hl",
                description_id = "ch_m4_vs_the_law",
                counter_id = "m4_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m4.head_shots do
            local name = "m4_head_shots_" .. i
            local count = definition.m4.head_shots[i].count
            local xp = definition.m4.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "m4_head_shots_" .. i - 1 or "m4_vs_the_law_3"
            }
            local depends_on = {challenges = challenges, weapons = nil}
            self.weapon[name] = {
                title_id = "ch_m4_head_shots_" .. i .. "_hl",
                description_id = "ch_m4_head_shots",
                counter_id = "m4_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m4.spooc_head_shot do
            local name = "m4_spooc_head_shot_" .. i
            local count = definition.m4.spooc_head_shot[i].count
            local xp = definition.m4.spooc_head_shot[i].xp
            local challenges = {
                i - 1 > 0 and "m4_spooc_head_shot" .. i - 1 or "m4_vs_the_law_5"
            }
            local depends_on = {challenges = challenges, weapons = nil}
            self.weapon[name] = {
                title_id = "ch_m4_spooc_head_shot_" .. i .. "_hl",
                description_id = "ch_m4_spooc_head_shot",
                counter_id = "m4_spooc_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_m14_challenges()
        local definition = {}
        definition.m14 = {}
        definition.m14.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.m14.head_shots = {
            {count = 75, xp = small_xp},
            {count = 200, xp = mid_xp},
            {count = 350, xp = large_xp},
            {count = 500, xp = large_xp}
        }
        definition.m14.taser_head_shot = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.m14.vs_the_law do
            local name = "m14_vs_the_law_" .. i
            local count = definition.m14.vs_the_law[i].count
            local xp = definition.m14.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "m14_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m14"}
            }
            self.weapon[name] = {
                title_id = "ch_m14_vs_the_law_" .. i .. "_hl",
                description_id = "ch_m14_vs_the_law",
                counter_id = "m14_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m14.head_shots do
            local name = "m14_head_shots_" .. i
            local count = definition.m14.head_shots[i].count
            local xp = definition.m14.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "m14_head_shots_" .. i - 1 or "m14_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m14"}
            }
            self.weapon[name] = {
                title_id = "ch_m14_head_shots_" .. i .. "_hl",
                description_id = "ch_m14_head_shots",
                counter_id = "m14_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m14.taser_head_shot do
            local name = "m14_taser_head_shot_" .. i
            local count = definition.m14.taser_head_shot[i].count
            local xp = definition.m14.taser_head_shot[i].xp
            local challenges = {
                i - 1 > 0 and "m14_taser_head_shot" .. i - 1 or "m14_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m14"}
            }
            self.weapon[name] = {
                title_id = "ch_m14_taser_head_shot_" .. i .. "_hl",
                description_id = "ch_m14_taser_head_shot",
                counter_id = "m14_taser_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_hk21_challenges()
        local definition = {}
        definition.hk21 = {}
        definition.hk21.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.hk21.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.hk21.shield_kill = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.hk21.vs_the_law do
            local name = "hk21_vs_the_law_" .. i
            local count = definition.hk21.vs_the_law[i].count
            local xp = definition.hk21.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "hk21_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"hk21"}
            }
            self.weapon[name] = {
                title_id = "ch_hk21_vs_the_law_" .. i .. "_hl",
                description_id = "ch_hk21_vs_the_law",
                counter_id = "hk21_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.hk21.head_shots do
            local name = "hk21_head_shots_" .. i
            local count = definition.hk21.head_shots[i].count
            local xp = definition.hk21.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "hk21_head_shots_" .. i - 1 or "hk21_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"hk21"}
            }
            self.weapon[name] = {
                title_id = "ch_hk21_head_shots_" .. i .. "_hl",
                description_id = "ch_hk21_head_shots",
                counter_id = "hk21_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.hk21.shield_kill do
            local name = "hk21_shield_kill_" .. i
            local count = definition.hk21.shield_kill[i].count
            local xp = definition.hk21.shield_kill[i].xp
            local challenges = {
                i - 1 > 0 and "hk21_shield_kill" .. i - 1 or "hk21_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"hk21"}
            }
            self.weapon[name] = {
                title_id = "ch_hk21_shield_kill_" .. i .. "_hl",
                description_id = "ch_hk21_shield_kill",
                counter_id = "hk21_shield_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_glock_challenges()
        local definition = {}
        definition.glock = {}
        definition.glock.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.glock.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.glock.shield_body_shots = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.glock.vs_the_law do
            local name = "glock_vs_the_law_" .. i
            local count = definition.glock.vs_the_law[i].count
            local xp = definition.glock.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "glock_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"glock"}
            }
            self.weapon[name] = {
                title_id = "ch_glock_vs_the_law_" .. i .. "_hl",
                description_id = "ch_glock_vs_the_law",
                counter_id = "glock_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.glock.head_shots do
            local name = "glock_head_shots_" .. i
            local count = definition.glock.head_shots[i].count
            local xp = definition.glock.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "glock_head_shots_" .. i - 1 or "glock_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"glock"}
            }
            self.weapon[name] = {
                title_id = "ch_glock_head_shots_" .. i .. "_hl",
                description_id = "ch_glock_head_shots",
                counter_id = "glock_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.glock.shield_body_shots do
            local name = "glock_shield_body_shots_" .. i
            local count = definition.glock.shield_body_shots[i].count
            local xp = definition.glock.shield_body_shots[i].xp
            local challenges = {
                i - 1 > 0 and "glock_shield_body_shots" .. i - 1 or "glock_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"glock"}
            }
            self.weapon[name] = {
                title_id = "ch_glock_shield_body_shot_" .. i .. "_hl",
                description_id = "ch_glock_shield_body_shot",
                counter_id = "glock_shield_body_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_ak47_challenges()
        local definition = {}
        definition.ak47 = {}
        definition.ak47.vs_the_law = {
            {count = 25, xp = tiny_xp},
            {count = 50, xp = small_xp},
            {count = 75, xp = mid_xp},
            {count = 100, xp = large_xp},
            {count = 125, xp = large_xp},
            {count = 150, xp = large_xp}
        }
        definition.ak47.head_shots = {
            {count = 25, xp = small_xp},
            {count = 50, xp = mid_xp},
            {count = 75, xp = large_xp},
            {count = 100, xp = large_xp}
        }
        definition.ak47.taser_kill = {
            {count = 5, xp = huge_xp}
        }
        for i = 1, #definition.ak47.vs_the_law do
            local name = "ak47_vs_the_law_" .. i
            local count = definition.ak47.vs_the_law[i].count
            local xp = definition.ak47.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "ak47_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"ak47"}
            }
            self.weapon[name] = {
                title_id = "ch_ak47_vs_the_law_" .. i .. "_hl",
                description_id = "ch_ak47_vs_the_law",
                counter_id = "ak47_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.ak47.head_shots do
            local name = "ak47_head_shots_" .. i
            local count = definition.ak47.head_shots[i].count
            local xp = definition.ak47.head_shots[i].xp
            local challenges = {
                i - 1 > 0 and "ak47_head_shots_" .. i - 1 or "ak47_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"ak47"}
            }
            self.weapon[name] = {
                title_id = "ch_ak47_head_shots_" .. i .. "_hl",
                description_id = "ch_ak47_head_shots",
                counter_id = "ak47_law_head_shot",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.ak47.taser_kill do
            local name = "ak47_taser_kill_" .. i
            local count = definition.ak47.taser_kill[i].count
            local xp = definition.ak47.taser_kill[i].xp
            local challenges = {
                i - 1 > 0 and "ak47_taser_kill" .. i - 1 or "ak47_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"ak47"}
            }
            self.weapon[name] = {
                title_id = "ch_ak47_taser_kill_" .. i .. "_hl",
                description_id = "ch_ak47_taser_kill",
                counter_id = "ak47_taser_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_m79_challenges()
        local definition = {}
        definition.m79 = {}
        definition.m79.vs_the_law = {
            {count = 5, xp = tiny_xp},
            {count = 10, xp = small_xp},
            {count = 15, xp = mid_xp},
            {count = 20, xp = large_xp},
            {count = 25, xp = large_xp},
            {count = 30, xp = large_xp}
        }
        definition.m79.simultaneous_kills = {
            {count = 2, xp = small_xp},
            {count = 4, xp = mid_xp},
            {count = 6, xp = large_xp},
            {count = 8, xp = large_xp}
        }
        definition.m79.simultaneous_specials = {
            {count = 2, xp = huge_xp}
        }
        for i = 1, #definition.m79.vs_the_law do
            local name = "m79_vs_the_law_" .. i
            local count = definition.m79.vs_the_law[i].count
            local xp = definition.m79.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "m79_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m79"}
            }
            self.weapon[name] = {
                title_id = "ch_m79_vs_the_law_" .. i .. "_hl",
                description_id = "ch_m79_vs_the_law",
                counter_id = "m79_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m79.simultaneous_kills do
            local name = "m79_simultaneous_kills_" .. i
            local count = definition.m79.simultaneous_kills[i].count
            local xp = definition.m79.simultaneous_kills[i].xp
            local challenges = {
                i - 1 > 0 and "m79_simultaneous_kills_" .. i - 1 or "m79_vs_the_law_3"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m79"}
            }
            self.weapon[name] = {
                title_id = "ch_m79_simultaneous_kills_" .. i .. "_hl",
                description_id = "ch_m79_simultaneous_kills",
                counter_id = "m79_law_simultaneous_kills",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.m79.simultaneous_specials do
            local name = "m79_taser_kill_" .. i
            local count = definition.m79.simultaneous_specials[i].count
            local xp = definition.m79.simultaneous_specials[i].xp
            local challenges = {
                i - 1 > 0 and "m79_simultaneous_specials" .. i - 1 or "m79_vs_the_law_5"
            }
            local depends_on = {
                challenges = challenges,
                weapons = {"m79"}
            }
            self.weapon[name] = {
                title_id = "ch_m79_simultaneous_specials_" .. i .. "_hl",
                description_id = "ch_m79_simultaneous_specials",
                counter_id = "m79_simultaneous_specials",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
    end
    function ChallengesTweakData:_sentry_gun_challenges()
        local definition = {}
        definition.sentry_gun = {}
        definition.sentry_gun.vs_the_law = {
            {count = 15, xp = tiny_xp},
            {count = 30, xp = small_xp},
            {count = 45, xp = mid_xp},
            {count = 60, xp = large_xp},
            {count = 75, xp = large_xp},
            {count = 90, xp = large_xp}
        }
        definition.sentry_gun.row_kills = {
            {count = 2, xp = small_xp},
            {count = 4, xp = mid_xp},
            {count = 6, xp = large_xp},
            {count = 8, xp = large_xp}
        }
        for i = 1, #definition.sentry_gun.vs_the_law do
            local name = "sentry_gun_vs_the_law_" .. i
            local count = definition.sentry_gun.vs_the_law[i].count
            local xp = definition.sentry_gun.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "sentry_gun_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_sentry_gun_vs_the_law_" .. i .. "_hl",
                description_id = "ch_sentry_gun_vs_the_law",
                counter_id = "sentry_gun_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        for i = 1, #definition.sentry_gun.row_kills do
            local name = "sentry_gun_row_kills_" .. i
            local count = definition.sentry_gun.row_kills[i].count
            local xp = definition.sentry_gun.row_kills[i].xp
            local challenges = {
                i - 1 > 0 and "sentry_gun_row_kills_" .. i - 1 or "sentry_gun_vs_the_law_3"
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_sentry_gun_row_kills_" .. i .. "_hl",
                description_id = "ch_sentry_gun_row_kills",
                counter_id = "sentry_gun_law_row_kills",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        self.weapon.sentry_gun_resources = {
            title_id = "ch_sentry_gun_resources_hl",
            description_id = "ch_sentry_gun_resources",
            flag_id = "sentry_gun_resources",
            unlock_level = 0,
            xp = huge_xp,
            depends_on = {
                challenges = {
                    "sentry_gun_vs_the_law_5"
                }
            }
        }
    end
    function ChallengesTweakData:_trip_mine_challenges()
        self.weapon.plant_tripmine = {
            title_id = "ch_plant_tripmine_hl",
            description_id = "ch_plant_tripmine",
            counter_id = "plant_tripmine",
            unlock_level = 0,
            count = 10,
            xp = mid_xp,
            depends_on = {
                equipment = {"trip_mine"}
            }
        }
        local definition = {}
        definition.trip_mine = {}
        definition.trip_mine.vs_the_law = {
            {count = 10, xp = tiny_xp},
            {count = 20, xp = small_xp},
            {count = 30, xp = mid_xp},
            {count = 40, xp = large_xp}
        }
        for i = 1, #definition.trip_mine.vs_the_law do
            local name = "trip_mine_vs_the_law_" .. i
            local count = definition.trip_mine.vs_the_law[i].count
            local xp = definition.trip_mine.vs_the_law[i].xp
            local challenges = {
                0 < i - 1 and "trip_mine_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {
                challenges = challenges,
                equipment = {"trip_mine"}
            }
            self.weapon[name] = {
                title_id = "ch_trip_mine_vs_the_law_" .. i .. "_hl",
                description_id = "ch_trip_mine_vs_the_law",
                counter_id = "trip_mine_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        self.weapon.dual_tripmine = {
            title_id = "ch_dual_tripmine_hl",
            description_id = "ch_dual_tripmine",
            counter_id = "dual_tripmine",
            unlock_level = 0,
            count = 1,
            xp = mid_xp,
            depends_on = {
                challenges = {
                    "trip_mine_vs_the_law_2"
                },
                equipment = {"trip_mine"}
            }
        }
        self.weapon.tris_tripmine = {
            title_id = "ch_tris_tripmine_hl",
            description_id = "ch_tris_tripmine",
            counter_id = "tris_tripmine",
            unlock_level = 0,
            count = 1,
            xp = large_xp,
            depends_on = {
                challenges = {
                    "dual_tripmine"
                },
                equipment = {"trip_mine"}
            }
        }
        self.weapon.quad_tripmine = {
            title_id = "ch_quad_tripmine_hl",
            description_id = "ch_quad_tripmine",
            counter_id = "quad_tripmine",
            unlock_level = 0,
            count = 1,
            xp = huge_xp,
            depends_on = {
                challenges = {
                    "tris_tripmine"
                },
                equipment = {"trip_mine"}
            }
        }
    end
    function ChallengesTweakData:_bleed_out_challenges()
        local definition = {}
        definition.bleed_out = {}
        definition.bleed_out.vs_the_law = {
            {count = 10, xp = small_xp},
            {count = 20, xp = small_xp},
            {count = 30, xp = mid_xp},
            {count = 40, xp = large_xp}
        }
        for i = 1, #definition.bleed_out.vs_the_law do
            local name = "bleed_out_vs_the_law_" .. i
            local count = definition.bleed_out.vs_the_law[i].count
            local xp = definition.bleed_out.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "bleed_out_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_bleed_out_kill_" .. i .. "_hl",
                description_id = "ch_bleed_out_kill",
                counter_id = "bleed_out_kill",
                unlock_level = 30,
                count = count,
                xp = xp,
                depends_on = depends_on
            }
        end
        self.weapon.bleed_out_multikill = {
            title_id = "ch_bleed_out_multikill_hl",
            description_id = "ch_bleed_out_multikill",
            counter_id = "bleed_out_multikill",
            unlock_level = 30,
            count = 5,
            xp = huge_xp,
            reset_criterias = {
                "exit_bleed_out"
            },
            depends_on = {
                challenges = {
                    "bleed_out_vs_the_law_4"
                }
            }
        }
        self.weapon.grim_reaper = {
            title_id = "ch_grim_reaper_hl",
            description_id = "ch_grim_reaper",
            counter_id = "grim_reaper",
            unlock_level = 30,
            count = 1,
            xp = large_xp,
            depends_on = {
                challenges = {
                    "bleed_out_multikill"
                }
            }
        }
    end
    function ChallengesTweakData:_melee_challenges()
        local definition = {}
        definition.melee = {}
        definition.melee.vs_the_law = {
            {
                count = 10,
                xp = tiny_xp,
                in_trial = true
            },
            {count = 10, xp = small_xp},
            {count = 20, xp = mid_xp},
            {count = 30, xp = large_xp}
        }
        for i = 1, #definition.melee.vs_the_law do
            local name = "melee_vs_the_law_" .. i
            local count = definition.melee.vs_the_law[i].count
            local xp = definition.melee.vs_the_law[i].xp
            local challenges = {
                i - 1 > 0 and "melee_vs_the_law_" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.weapon[name] = {
                title_id = "ch_melee_" .. i .. "_hl",
                description_id = "ch_melee",
                counter_id = "melee_law_kill",
                unlock_level = 0,
                count = count,
                xp = xp,
                depends_on = depends_on,
                in_trial = definition.melee.vs_the_law[i].in_trial
            }
        end
    end
    function ChallengesTweakData:_money_challenges()
        local definition = {}
        definition.money = {}
        definition.money.aquire = {
            {
                amount = 20000,
                xp = mid_xp,
                in_trial = true
            },
            {amount = 50000, xp = mid_xp},
            {amount = 100000, xp = large_xp},
            {amount = 200000, xp = large_xp},
            {amount = 300000, xp = large_xp},
            {amount = 400000, xp = huge_xp},
            {amount = 500000, xp = huge_xp},
            {amount = 600000, xp = gigantic_xp},
            {amount = 800000, xp = gigantic_xp},
            {
                amount = 1000000,
                xp = gigantic_xp,
                awards_achievment = "payday"
            }
        }
        for i = 1, #definition.money.aquire do
            local name = "aquire_money" .. i
            local amount = definition.money.aquire[i].amount
            local xp = definition.money.aquire[i].xp
            local awards_achievment = definition.money.aquire[i].awards_achievment
            local challenges = {
                i - 1 > 0 and "aquire_money" .. i - 1 or nil
            }
            local depends_on = {challenges = challenges}
            self.session[name] = {
                title_id = "ch_aquire_money_" .. i .. "_hl",
                description_id = "ch_aquire_money_" .. i,
                unlock_level = 0,
                amount = amount,
                xp = xp,
                awards_achievment = awards_achievment,
                depends_on = depends_on,
                id = "aquired_money",
                in_trial = definition.money.aquire[i].in_trial
            }
        end
    end
    
end




