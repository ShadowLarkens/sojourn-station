/obj/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()

/obj/mecha/ui_data(mob/user)
	var/list/data = list()

	return data

/obj/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	