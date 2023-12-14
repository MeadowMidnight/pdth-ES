# PD:TH Enhanced Singleplayer
A mod for Payday: The Heist that adds player-side and team AI enhancements in singleplayer heists whilst adding optional gameplay changes which can be toggled to suit your tastes.

IMPORTANT NOTE: While this mod is active you won't be able to play multiplayer at all, along with achievements and steam statistics being completely disabled. This mod will also create a new save file so you can't just farm XP from challenges or heist completions on your main save, leaving it untouched from modded gameplay.

There is a keybind that increases your progression to the max reputation level in the mod settings.

# Installation:
This mod requires the DAHM modification which can be found here: https://steamcommunity.com/groups/dahm4pd/discussions/3/3810655600549061009/

Simply extract the file and place it in the "mods" folder in the game directory.

When uninstalling this mod, DO NOT disable it in the mod settings in-game, just delete or move the pdth-ES folder from the mods folder to prevent save corruption.

# Features:
  
From the mod settings, you can select up to 3 crew bonuses that the bots can give to you. (They DO NOT stack when the same one is used.)
- Aggressor (10% damage bonus)
- Protector (10% more armor)
- Sharpshooter (10% less spread)
- Big Game Hunters (15% more ammo)
- Speed Reloaders (10% faster reload speed)
- Noob Lube (20% more experience)
- Mr Nice Guy (20% more experience)

When both Mr Nice Guy and Noob Lube are used, they give 44% more experience.

These bonuses will always be active, even if the bots are downed, in custody or playing without them.

You can change the crew bonuses to "Not Active" if you don't want them.

There is also a mod setting where you can enable buffed crew bonuses, which enhances underused crew bonuses.
- Sharpshooter: 10% -> 25%
- Protector: 10% -> 50%
- Speed Reloaders: 10% -> 20%

Another mod setting present is the weapon rebalance option, which rebalances all the weapons in the game.
- All weapons except the GL40 have fixed ammo pickup, meaning it's no longer randomized.

Handguns:

B9-S:
- Damage: 1 -> 1.5
- Ammo: 56 -> 80
- Ammo Pickup: {6, 8} -> {5, 5}

Crosskill 45:
- Damage: 1.5 -> 3
- Ammo: 50 -> 56
- Ammo Pickup: {4, 6} -> {3, 3}

Bronco:
- Reload time when empty: 4.6 -> 5.8 (unupgraded values)
- Ammo: 36 -> 30
- Spread when in ADS: 1.8 -> 0
- Ammo Pickup: {1, 2} -> {1, 1}

STRYK:
- Damage: 1 -> 1.5
- Ammo: 56 -> 160
- Ammo Pickup: {5, 7} -> {3, 3}
- Overall Spread is reduced by ~20%.
- No longer has ADS zoom.

Secondary:

Compact-5:
- Damage: 1.15 -> 1.5
- Ammo: 150 -> 120
- Ammo Pickup: {2, 7} -> {5, 5}
- Overall Spread is reduced by ~40%.

Mark 10:
- Damage: 1.3 -> 2.4
- Ammo: 120 -> 108
- Ammo Pickup: {2, 7} -> {4, 4}
- Firerate: 0.066 -> 0.05

Locomotive:
- Damage: 4 -> 6
- Ammo Pickup: {0, 1} -> {1, 1}

GL40:
- Now a primary weapon instead of a secondary.
- Damage: 40 -> 60
- Explosion Range: 500 -> 600
- Ammo Pickup: {-4, 1} -> {-2, 1}

Primary:
AMCAR-4:
- Ammo Pickup: {2, 10} -> {6, 6}
- Horizontal Recoil (ADS): -0.45 -> 0.1
- Vertical Recoil (ADS): -0.45 -> 0.1

Brenner:
- Firerate: 0.1333 -> 0.075
- Magazine Size: 160 -> 120 (with all upgrades)
- Ammo Pickup: {2, 10} -> {7, 7}

M308:
- Ammo: 72 -> 64
- Ammo Pickup: {1, 5} -> {3, 3}

Reinbeck:
- Firerate: 0.8 -> 0.9
- Ammo Pickup: {1, 2} -> {2, 2}

AK Rifle:
- Firerate: 0.07 -> 0.09
- Ammo: 125 -> 140
- Ammo Pickup: {2, 8} -> {4, 4}

# Progression Changes:
Challenges have went through several changes:
  - Challenges now give 2x the amount of XP then they normally did in vanilla, making grinding less tedious and easier to level up from a new save.
  - Sentry Gun VS The World is now possible due to the player now being able to hold 4 sentry guns at once.
  - Repetitive challenges like weapon kills had their requirements lowered due to them being boring to complete.
  - Overdrill is now possible to trigger in Singleplayer.
  - Quick Hands is now possible because of the 0.1 second interaction times for defusing C4. (Yes, I know this is a band-aid and janky fix)
  - Noob Herder is now possible if all 3 bot crew bonuses are set to Noob Lube and the difficulty is on Overkill or above in the heist.
  - Challenges don't give Steam achievements in this mod.
  - No Photos is now earned by simply destroying a single camera, but it gives less XP.
  - Last Christmas is now possible in Singleplayer. (The presents only spawned in Multiplayer previously.)

Cash Changes:
- Loot pickups such as cash, gold and diamonds had their values adjusted, and they scale depending on the difficulty played.
- End of heist rewards were tweaked.
- You no longer fully replenish both health and ammo when reaching a new reputation level on Hard difficulty or lower.
- You now earn $100k per camera destroyed in a heist.
- Slaugherhouse gives $500k per gold secured, it increases up to $2500k on Overkill 145+
- Counterfeit money found in the basement only gives $400k on Easy, up to $2000k on Overkill 145+
- The same values above apply to the 70 pieces of gold found in the Overdrill vault in First World Bank, as they both share the same data.
- The blue sapphires found in Diamond Heist give $200k, up to $1000k on Overkill 145+
- Same thing applies to the diamonds in the vault in the same heist mentioned, the money randomly found in First World Bank, Panic Room and Slaughterhouse and the necklace in Counterfeit.
- The blood diamond in Diamond Heist and bracelets found in Counterfeit had their values adjusted.
- Finding a christmas present during a heist will give $500k to $2500k depending on the difficulty selected.

# Gameplay Changes:
Team AI Changes:
- Bot HP is now shown on the in-game HUD.
- Bots will no longer screw up stealth if they fire their weapon against the guard that appears in No Mercy or the cops that arrive in Counterfeit.
- Bots will no longer attempt to dodge police shots by randomly moving.
- Bots won't get knocked down after receiving heavy damage.
- Bot movement speed has been changed to 600 (default) and is consistent for all members.
- Bots will no longer get arrested by cloakers. (There is an option to turn this off in the mod settings.)
  
Equipment Changes:
- You have 2 ammo bags or 2 doctor bags now, at the cost of only 4 total uses from doctor bags (2 uses per bag, previously 5 uses from a single bag in vanilla) and ammo bag percentage total remains unchanged. (500% per bag, totalling up to 1000%)
- You now have 4 sentry guns you can deploy, the rest of their stats remain unchanged.
- You have 8 cable ties due to missing players in singleplayer.
- You can now carry 2 thermite/gasoline, 9 pieces of C4 and 4 blood samples at once.
- You get 2 extra trip mines.

Misc Changes:
- You can now play all heists on Easy difficulty.
- Cops and civilians will no longer absorb bullets if they are already dead.
