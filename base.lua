local module = DorHUDMod:new("Enhanced Singleplayer", { abbr = "ES",
	author = "MeadowMidnight", description = {
		english = "Adds player-side and team AI enhancements in singleplayer heists whilst trying to leave enemy-side balance untouched. Joining multiplayer lobbies, unlocking achievements and saving steam statistics are disabled while this mod is active."
	}
})
module:hook_post_require("lib/network/matchmaking/networkaccountsteam", "enhanced_singleplayer")
module:hook_post_require("lib/managers/menumanager", "enhanced_singleplayer")
module:hook_post_require("lib/units/weapons/raycastweaponbase", "enhanced_singleplayer")
module:hook_post_require("lib/units/weapons/grenades/m79grenadebase", "enhanced_singleplayer")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "enhanced_singleplayer")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/charactertweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/units/player_team/teamaidamage", "enhanced_singleplayer")
module:hook_post_require("lib/units/player_team/teamaimovement", "enhanced_singleplayer")
module:hook_post_require("lib/units/props/timergui", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/tweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/playertweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/equipmentstweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/upgradestweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/weapontweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/tweak_data/challengestweakdata", "enhanced_singleplayer")
module:hook_post_require("lib/managers/achievmentmanager", "enhanced_singleplayer")
module:hook_post_require("lib/managers/hudmanager", "enhanced_singleplayer")
module:hook_post_require("lib/managers/missionmanager", "enhanced_singleplayer")
module:hook_post_require("lib/managers/savefilemanager", "enhanced_singleplayer")
module:hook_post_require("lib/managers/experiencemanager", "enhanced_singleplayer")
module:hook_post_require("lib/units/props/christmaspresentbase", "enhanced_singleplayer")
module:hook_post_require("lib/network/matchmaking/networkmatchmakingsteam", "enhanced_singleplayer")
module:hook_post_require("lib/units/beings/player/playerdamage", "enhanced_singleplayer")
module:hook_post_require("lib/states/missionendstate", "enhanced_singleplayer")
module:hook_post_require("lib/units/beings/player/states/playerstandard", "enhanced_singleplayer")
module:hook_post_require("lib/units/beings/player/states/playertased", "enhanced_singleplayer")
module:hook_post_require("lib/units/props/securitycamera", "enhanced_singleplayer")
module:hook_post_require("lib/units/props/securitylockgui", "enhanced_singleplayer")

module:register_include("modloc", { type = "localization" })

module:register_include("modsetup", { type = "settings" })
return module
