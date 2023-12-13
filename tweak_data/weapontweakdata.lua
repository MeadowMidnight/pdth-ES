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
	self.m79.NR_CLIPS_MAX = 4
	self.m79.AMMO_PICKUP = {-2, 1}
	self.m79.use_data.selection_index = 2

	self.mossberg.DAMAGE = 6
	self.mossberg.AMMO_PICKUP = {1, 1}

	self.mac11.AMMO_MAX = 90
	self.mac11.AMMO_PICKUP = {4, 4}
	self.mac11.DAMAGE = 2.4
	self.mac11.auto.fire_rate = 0.05

	self.beretta92.DAMAGE = 2

	self.beretta92.spread.standing = 2
	self.beretta92.spread.crouching = 1.4
	self.beretta92.spread.steelsight = 0.8
	self.beretta92.spread.moving_standing = 2
	self.beretta92.spread.moving_crouching = 2

	self.c45.CLIP_AMMO_MAX = 8
	self.c45.AMMO_MAX = 36
	self.c45.AMMO_PICKUP = {2, 2}
	self.c45.DAMAGE = 3.5

	self.c45.spread.standing = 3
	self.c45.spread.crouching = 2.1
	self.c45.spread.steelsight = 1.2
	self.c45.spread.moving_standing = 3.5
	self.c45.spread.moving_crouching = 3.5

	self.glock.AMMO_MAX = 80
	self.glock.AMMO_PICKUP = {3, 3}
	self.glock.DAMAGE = 1.75

	self.glock.spread.standing = 3.5
	self.glock.spread.crouching = 2.45
	self.glock.spread.steelsight = 1.4
	self.glock.spread.moving_standing = 3.5
	self.glock.spread.moving_crouching = 3.5
	

	self.m4.kick.v.steelsight = 0.1
	self.m4.kick.h.steelsight = 0.1

	self.m14.AMMO_MAX = 60
	self.m14.AMMO_PICKUP = {3, 3}


	self.mp5.DAMAGE = 1.6
	self.mp5.AMMO_MAX = 120
	self.mp5.AMMO_PICKUP = {5, 5}

	self.mp5.spread.standing = 2.1 
	self.mp5.spread.crouching = 1.5
	self.mp5.spread.steelsight = 1.02
	self.mp5.spread.moving_standing = 2.7
	self.mp5.spread.moving_crouching = 2.28

	self.r870_shotgun.single.fire_rate = 1
	self.ak47.auto.fire_rate = 0.09
	
	self.hk21.auto.fire_rate = 0.075

	self.raging_bull.timers.reload_empty = 5.8
end, false)
local diff_overhaul = D:conf("difficulty_overhaul") or false
if diff_overhaul then
	module:post_hook(WeaponTweakData, "_init_data_r870_npc", function(self)
		self.r870_npc.DAMAGE = 5
	end, false)
	module:post_hook(WeaponTweakData, "_init_data_sniper_rifle_npc", function(self)
		self.sniper_rifle_npc.DAMAGE = 1.5
	end, false)
	module:post_hook(WeaponTweakData, "_init_data_m4_npc", function(self)
		self.m4_npc.DAMAGE = 1.5
	end, false)
	module:post_hook(WeaponTweakData, "_init_data_mac11_npc", function(self)
		self.mac11_npc.DAMAGE = 0.8
	end, false)
end