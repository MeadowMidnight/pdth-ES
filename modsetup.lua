local module = ...

-- Menu Options --
module:add_menu_option("crew_bonus_1", {
	type = "multi_choice",
	text_id = "crew_bonus_name",
	help_id = "crew_bonus_description",
	choices = {{"disabled", "not_active"},{"protector", "protector_text"},{"aggressor", "aggressor_text"},{"more_blood_to_bleed", "bleed_text"},{"big_game_hunters", "hunters_text"},{"sharpshooters", "sharpshooters_text"},{"speed_reloaders", "speed_reloaders_text"}, {"noob_lube", "noob_text"}, {"nice_guy", "nice_text"}},
	default_value = "disabled"
})
module:add_menu_option("crew_bonus_2", {
	type = "multi_choice",
	text_id = "crew_bonus_name2",
	help_id = "crew_bonus_description",
	choices = {{"disabled", "not_active"},{"protector", "protector_text"},{"aggressor", "aggressor_text"},{"more_blood_to_bleed", "bleed_text"},{"big_game_hunters", "hunters_text"},{"sharpshooters", "sharpshooters_text"},{"speed_reloaders", "speed_reloaders_text"}, {"noob_lube", "noob_text"}, {"nice_guy", "nice_text"}},
	default_value = "disabled"
})
module:add_menu_option("crew_bonus_3", {
	type = "multi_choice",
	text_id = "crew_bonus_name3",
	help_id = "crew_bonus_description",
	choices = {{"disabled", "not_active"},{"protector", "protector_text"},{"aggressor", "aggressor_text"},{"more_blood_to_bleed", "bleed_text"},{"big_game_hunters", "hunters_text"},{"sharpshooters", "sharpshooters_text"},{"speed_reloaders", "speed_reloaders_text"}, {"noob_lube", "noob_text"}, {"nice_guy", "nice_text"}},
	default_value = "disabled"
})
module:add_menu_option("vanilla_weapons", {
	type = "boolean",
	text_id = "VW_name",
	help_id = "VW_desc",
	default_value = false
})
module:add_menu_option("vanilla_bonuses", {
	type = "boolean",
	text_id = "VB_name",
	help_id = "VB_desc",
	default_value = false
})
module:add_menu_option("bot_arrest", {
	type = "boolean",
	text_id = "BA_name",
	help_id = "BA_desc",
	default_value = false
})
module:add_menu_option("bot_health", {	
	type = "slider",
	min = 30, max = 300, step = 10,
	show_value = true,
	text_id = "BH_name",
	help_id = "BH_desc",
	default_value = 750
})
module:add_menu_option("bot_speed", {
	type = "slider",
	min = 100, max = 1200, step = 20,
	show_value = true,
	text_id = "BS_name",
	help_id = "BS_desc",
	default_value = 600
})
module:add_menu_option("bot_regen", {
	type = "slider",
	min = 1, max = 10, step = 0.1,
	show_value = true,
	text_id = "BR_name",
	help_id = "BR_desc",
	value_accuracy = 2,
	default_value = 2.5
})

module:add_menu_option("max_key", {
	type = "keybind",
	name = {
		english = "Max Progression Keybind:"
	}
})
local function max_out()
	managers.experience:add_points(50000000, true)
end
module:hook("OnKeyPressed", "max_key", nil, "GAME", function()
	max_out()
end)