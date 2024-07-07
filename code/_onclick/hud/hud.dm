/datum/hud
	var/mob/mymob = null
	var/is_minimal = FALSE

	// Eris HUD /obj/screen storage
	var/list/HUDneed = list() // What HUD object need see
	var/list/HUDinventory = list()
	var/list/HUDfrippery = list()//flavor
	var/list/HUDprocess = list() //What HUD object need process
	var/list/HUDtech = list()

	// plane master / openspace overlay vars
	var/old_z
	var/list/obj/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object
	var/list/obj/screen/openspace_overlay/openspace_overlays = list()

	// Elements used for action buttons
	// -- the main clickable buttons
	var/obj/screen/action_palette/toggle_palette
	var/obj/screen/palette_scroll/down/palette_down
	var/obj/screen/palette_scroll/up/palette_up
	/// the groups of actions, such as palette (previously normal) actions
	var/datum/action_group/palette/palette_actions
	/// action group for cult spell actions
	var/datum/action_group/listed/cult/cult_actions
	/// action group for expanded actions, the normal action set
	var/datum/action_group/listed/listed_actions
	/// A list of action buttons which aren't owned by any action group, and are just floating somewhere on the hud.
	var/list/floating_actions

/datum/hud/New(mob/owner)
	mymob = owner
	updatePlaneMasters()

/datum/hud/Destroy()
	mymob = null
	. = ..()

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		if(!ispath(hud_type))
			// All mobs must have some type of hud - /datum/hud itself will handle action buttons and plane masters only
			CRASH("HUD type must be a type, was instead [hud_type]!")
		hud_used = new hud_type(src)

/datum/hud/proc/ui_palette_scroll_offset(north_offset)
	return "WEST+1:8,NORTH-[6+north_offset]:15"

/datum/hud/proc/clear()
	HUDprocess.Cut()
	QDEL_LIST_ASSOC_VAL(HUDneed)
	QDEL_LIST(HUDinventory)
	QDEL_LIST(HUDfrippery)
	QDEL_LIST_ASSOC_VAL(HUDtech)

/datum/hud/proc/show()
	var/client/C = mymob?.client
	if(C)
		for(var/p in HUDneed)
			C.screen += HUDneed[p]
		for(var/p in HUDinventory)
			C.screen += p
		for(var/p in HUDtech)
			C.screen += HUDtech[p]
		reorganize_alerts()
		// Always recalculate plane masters on show(), this is called in login()
		updatePlaneMasters(force = TRUE)
		return TRUE
	return FALSE

// Sometimes you gotta recreate the entire HUD
/datum/hud/proc/force_recreate()
	return !!mymob?.client

/datum/hud/proc/update_hud()
	return !!mymob?.client

/datum/hud/proc/recolor_HUD(_color, _alpha)
	for(var/p in HUDneed)
		var/obj/screen/HUDelm = HUDneed[p]
		HUDelm.color = _color
		HUDelm.alpha = _alpha
	for(var/obj/screen/HUDinv in HUDinventory)
		HUDinv.color = _color
		HUDinv.alpha = _alpha

/mob/update_plane()
	..()
	if(hud_used)
		hud_used.updatePlaneMasters(src)

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(!hud_used)
		to_chat(usr, SPAN_WARNING("This mob type does not use a HUD."))
		return

	if(!ishuman(src))
		to_chat(usr, SPAN_WARNING("Inventory hiding is currently only supported for human mobs, sorry."))
		return

	if(!client) return
	if(client.view != world.view)
		return

	update_action_buttons()

//Similar to button_pressed_F12() but keeps zone_sel, gun_setting_icon, and healths.
/mob/proc/toggle_zoom_hud()
	if(!hud_used)
		return
	if(!ishuman(src))
		return
	if(!client)
		return
	if(client.view != world.view)
		return

	update_action_buttons()
