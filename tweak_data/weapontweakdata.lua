local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local module = ...
local rebalanced_weapons = D:conf("rebalanced_weapons") or false
if not is_singleplayer then
	return
end
local WeaponTweakData = module:hook_class("WeaponTweakData")
module:post_hook(WeaponTweakData, "_init_data_player_weapons", function(self)
	if not rebalanced_weapons then
		return
	end
	self.m79.DAMAGE = 60
	self.m79.EXPLOSION_RANGE = 600
	self.m79.AMMO_PICKUP = {-2, 1}
	self.m79.use_data.selection_index = 2

	self.mossberg.DAMAGE = 6
	self.mossberg.AMMO_PICKUP = {1, 1}

	self.mac11.AMMO_MAX = 108
	self.mac11.AMMO_PICKUP = {4, 4}
	self.mac11.DAMAGE = 2.4
	self.mac11.auto.fire_rate = 0.05

	self.m14.AMMO_PICKUP = {3, 3}
	self.m14.AMMO_MAX = 64

	self.beretta92.DAMAGE = 1.5
	self.beretta92.AMMO_MAX = 80
	self.beretta92.AMMO_PICKUP = {5, 5}

	self.c45.AMMO_MAX = 56
	self.c45.AMMO_PICKUP = {3, 3}
	self.c45.DAMAGE = 3

	self.glock.AMMO_MAX = 160
	self.glock.AMMO_PICKUP = {3, 3}
	self.glock.DAMAGE = 1.25

	self.glock.spread.standing = 3.2
	self.glock.spread.crouching = 3.2
	self.glock.spread.steelsight = 1.28
	self.glock.spread.moving_standing = 3.2
	self.glock.spread.moving_crouching = 3.2
	

	self.m4.kick.v.steelsight = 0.1
	self.m4.kick.h.steelsight = 0.1
	self.m4.AMMO_PICKUP = {6, 6}

	self.mp5.DAMAGE = 1.5
	self.mp5.AMMO_MAX = 120
	self.mp5.AMMO_PICKUP = {5, 5}

	self.mp5.spread.standing = 2.1 
	self.mp5.spread.crouching = 1.5
	self.mp5.spread.steelsight = 1.02
	self.mp5.spread.moving_standing = 2.7
	self.mp5.spread.moving_crouching = 2.28

	self.r870_shotgun.single.fire_rate = 0.9
	self.r870_shotgun.AMMO_PICKUP = {2, 2}

	self.ak47.auto.fire_rate = 0.09
	self.ak47.AMMO_MAX = 140
	self.ak47.AMMO_PICKUP = {4, 4}
	
	self.hk21.auto.fire_rate = 0.075
	self.hk21.CLIP_AMMO_MAX = 40
	self.hk21.AMMO_PICKUP = {7, 7}

	self.raging_bull.timers.reload_empty = 5.8
	self.raging_bull.AMMO_PICKUP = {1, 1}
	self.raging_bull.spread.steelsight = 0
	self.raging_bull.AMMO_MAX = 30
end, false)