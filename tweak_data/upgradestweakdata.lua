local is_singleplayer = Global.game_settings and Global.game_settings.single_player
if not is_singleplayer then
	return
end
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