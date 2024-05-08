/// Sends information needed for shared details on individual preferences
/datum/asset/json/preferences
	name = "preferences"

/datum/asset/json/preferences/generate()
	var/datum/category_collection/player_setup_collection/player_setup = new()
	return player_setup.get_constant_data()
