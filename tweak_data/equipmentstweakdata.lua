local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
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