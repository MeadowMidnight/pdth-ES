local module = DorHUDMod:new("Enhanced Singleplayer", { abbr = "ES",
	author = "MeadowMidnight", version = "1", description = {
		english = "Adds player-side and team AI enhancements in singleplayer heists whilst avoiding major changes to enemy-side balance. Joining multiplayer lobbies, unlocking achievements and saving steam statistics are disabled while this mod is active."
	}
})
module:register_include("modloc", { type = "localization" })

module:register_include("modsetup", { type = "settings" })

module:register_include("hooks", { type = "settings" })
return module
