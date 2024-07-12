/datum/tgui_module/strip_panel
	name = "Inventory"
	tgui_id = "StripPanel"

	var/refresh_next_allowed = 0
	var/simultaneous_acts = 0

/datum/tgui_module/strip_panel/New(new_host)
	if(!ismob(new_host))
		CRASH("Strip panel created for a non-mob!")
	. = ..()

/datum/tgui_module/strip_panel/ui_data(mob/user)
	// not used in modular computers so don't call ..()
	var/list/data = list()
	var/mob/M = host
	data["mob_name"] = "[M]"
	data["will_refresh"] = simultaneous_acts > 1

	return data

/datum/tgui_module/strip_panel/ui_static_data(mob/user)
	var/mob/M = host
	return M.get_strip_panel_data(user)

/datum/tgui_module/strip_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	simultaneous_acts++
	var/mob/M = host
	. = M.handle_stripping_actions(action, params)
	if(.)
		// They presumably removed something, we should update
		if(simultaneous_acts == 1)
			update_static_data_for_all_viewers()
		simultaneous_acts--
		return

	switch(action)
		if("refresh")
			// little cooldown to prevent spamming icon2html
			if(refresh_next_allowed > world.time)
				to_chat(usr, SPAN_WARNING("Rate limited, you can only refresh once every five seconds."))
				return
			update_static_data(usr, ui)
			refresh_next_allowed = world.time + 5 SECONDS
			. = TRUE

	simultaneous_acts--
