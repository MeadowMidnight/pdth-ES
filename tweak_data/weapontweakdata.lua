local is_singleplayer = Global.game_settings and Global.game_settings.single_player
local module = ...
local vanilla_weapons = D:conf("vanilla_weapons") or false
if not is_singleplayer then
	return
end
local WeaponTweakData = module:hook_class("WeaponTweakData")
module:post_hook(WeaponTweakData, "_init_data_player_weapons", function(self)
	if vanilla_weapons then
		return
	end
	-- GL40 --
	-- More damage, explosion range and ammo pickup at the cost of it now taking up your primary slot.
	self.m79.DAMAGE = 80
	self.m79.EXPLOSION_RANGE = 750
	self.m79.NR_CLIPS_MAX = 4
	self.m79.AMMO_PICKUP = {-2, 1}
	self.m79.use_data.selection_index = 2

	-- Locomotive --
	-- Direct buff, because it sucks in vanilla.
	self.mossberg.DAMAGE = 6
	self.mossberg.AMMO_PICKUP = {1, 1}

	--Mark 11 Ammo, Pickup, RoF & Damage
	self.mac11.AMMO_MAX = 90
	self.mac11.AMMO_PICKUP = {4, 4}
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
	self.c45.AMMO_PICKUP = {2, 2}
	self.c45.DAMAGE = 3.5 --from 1.5

	--Crosskill Accuracy
	self.c45.spread.standing = 3 -- from 4,5 (Bonus +33.3% ACC)
	self.c45.spread.crouching = 2.1 --4,5 (Base +31,1% ACC) (Modded +30% ACC)
	self.c45.spread.steelsight = 1.2 --1,7 (Base +62.2% ACC) (Modded +60% ACC)
	self.c45.spread.moving_standing = 3.5
	self.c45.spread.moving_crouching = 3.5

	--STRKY Ammo, Pickup & Damage
	self.glock.AMMO_MAX = 80 --from 56
	self.glock.AMMO_PICKUP = {3, 3}
	self.glock.DAMAGE = 1.75 --from 1

	--STRKY Accuracy
	self.glock.spread.standing = 3.5 --from 4 (Bonus +12.5% ACC)
	self.glock.spread.crouching = 2.45 --from 4 (Base +30% ACC)
	self.glock.spread.steelsight = 1.4 --from 1.6 (Base +60% ACC)
	self.glock.spread.moving_standing = 3.5 --from 4
	self.glock.spread.moving_crouching = 3.5 --from 4
	

	self.m4.kick.v.steelsight = 0.1 --0.45
	self.m4.kick.h.steelsight = 0.1 --0.45

	--M308 Ammo & Pickup
	self.m14.AMMO_MAX = 60
	self.m14.AMMO_PICKUP = {3, 3}


	--Compact 5 Ammo, Pickup & Damage
	self.mp5.DAMAGE = 1.6 --from 1.15
	self.mp5.AMMO_MAX = 120
	self.mp5.AMMO_PICKUP = {5, 5}

	-- ~40% less spread --
	self.mp5.spread.standing = 2.1 
	self.mp5.spread.crouching = 1.5
	self.mp5.spread.steelsight = 1.02
	self.mp5.spread.moving_standing = 2.7
	self.mp5.spread.moving_crouching = 2.28


	self.ak47.auto.fire_rate = 0.09
	
	self.hk21.auto.fire_rate = 0.075
end, false)