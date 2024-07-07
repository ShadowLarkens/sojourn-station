#define AB_ITEM 1
#define AB_SPELL 2
#define AB_INNATE 3
#define AB_GENERIC 4
#define AB_ITEM_PROC 5

#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_ALIVE 8
#define AB_CHECK_INSIDE 16


/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/action_type = AB_ITEM
	var/procname = null
	var/list/arguments
	var/atom/movable/target = null
	var/check_flags = 0
	var/processing = 0
	var/active = 0
	var/obj/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions/actions.dmi'
	var/button_icon_state = "default"
	var/background_icon_state = "bg_default"
	var/mob/owner

/datum/action/New(var/Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	. = ..()

/datum/action/proc/Grant(mob/living/T)
	if(owner)
		if(owner == T)
			return
		Remove(owner)
	owner = T
	owner.actions.Add(src)
	owner.update_action_buttons()
	return

/datum/action/proc/Remove(mob/living/T)
	if(button)
		if(T.client)
			T.client.screen -= button
		qdel(button)
		button = null
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null
	return

/datum/action/proc/Trigger()
	if(!Checks())
		return
	switch(action_type)
		if(AB_ITEM)
			if(target)
				var/obj/item/item = target
				item.ui_action_click(usr, name)
		//if(AB_SPELL)
		//	if(target)
		//		var/obj/effect/proc_holder/spell = target
		//		spell.Click()
		if(AB_INNATE)
			if(!active)
				Activate()
			else
				Deactivate()
		if(AB_GENERIC)
			if(target && procname)
				call(target, procname)(usr)
		if(AB_ITEM_PROC)
			if(target && procname)
				if(!arguments)
					arguments = usr
				call(target, procname)(arguments)
	return

/datum/action/proc/Activate()
	return

/datum/action/proc/Deactivate()
	return

/datum/action/Process()
	return

/datum/action/proc/CheckRemoval(mob/living/user) // 1 if action is no longer valid for this mob and should be removed
	return 0

/datum/action/proc/IsAvailable()
	return Checks()

/datum/action/proc/Checks()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned)
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat)
			return 0
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner))
			return 0
	return 1

/obj/screen/movable/action_button
	var/datum/action/owner
	screen_loc = "WEST,NORTH"

/obj/screen/movable/action_button/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	if(usr.next_move >= world.time) // Is this needed ?
		return
	owner.Trigger()
	return 1

/obj/screen/movable/action_button/MouseEntered(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(!QDELETED(src) && !LAZYACCESS(modifiers, DRAG) && !LAZYACCESS(modifiers, LEFT_CLICK))  // tooltips opening on drag prevents things from being dropped onto their actual objects)
		// if(!linked_keybind)
		openToolTip(usr, src, params, title = name, content = owner?.desc) //, theme = actiontooltipstyle)
		// else if(linked_keybind)
		// 	var/list/desc_information = list()
		// 	desc_information += desc
		// 	desc_information += "This action is currently bound to the [linked_keybind.binded_to] key."
		// 	desc_information = desc_information.Join(" ")
		// 	openToolTip(usr, src, params, title = name, content = desc_information, theme = actiontooltipstyle)

/obj/screen/movable/action_button/MouseExited(location, control, params)
	closeToolTip(usr)
	. = ..()

/obj/screen/movable/action_button/proc/UpdateIcon()
	if(!owner)
		return
	icon = owner.button_icon
	icon_state = owner.background_icon_state

	cut_overlays()
	var/image/img
	if((owner.action_type == AB_ITEM || owner.action_type == AB_ITEM_PROC) && owner.target)
		var/obj/item/I = owner.target
		img = image(I.icon, src , I.icon_state)
	else if(owner.button_icon && owner.button_icon_state)
		img = image(owner.button_icon, src, owner.button_icon_state)
	img.pixel_x = 0
	img.pixel_y = 0
	add_overlay(img)

	if(!owner.IsAvailable())
		color = rgb(128, 0, 0, 128)
	else
		color = rgb(255, 255, 255, 255)


// Action Palette: A new way to interact

/obj/screen/action_palette
	icon = 'icons/mob/screen/ErisStyleHolo.dmi'
	icon_state = "action_palette"
	desc = "<b>Drag</b> buttons to move them.<br><b>Shift-click</b> any button to reset it.<br><b>Alt-click</b> this to reset all buttons.<br><b>Ctrl-click</b> action buttons to lock or unlock them.<br><b>Ctrl-click</b> this to get a detailed explanation of how to use this."
	var/datum/hud/our_hud
	var/expanded = FALSE
	/// Id of any currently running timers that set our color matrix
	var/color_timer_id

/obj/screen/action_palette/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.toggle_palette = null
		our_hud = null
	return ..()

/obj/screen/action_palette/proc/set_hud(datum/hud/new_our_hud)
	our_hud = new_our_hud
	refresh_owner()

/obj/screen/action_palette/update_minimalized(minimalized)
	if(minimalized)
		icon_state = "action_palette_min"
	else
		icon_state = "action_palette"

/obj/screen/action_palette/CtrlClick(mob/user)
	if(!istype(user))
		return

	var/list/explanation = list()

	explanation.Insert(
		"<b><center>The Action Palette [icon2base64html(src)] and You</center></b>",
		"The Action Palette [icon2base64html(src)] is the new way to hide action buttons. You can hide only some buttons, and quickly bring them up when needed, instead of hiding all of them.",
		"To use it, drag action buttons onto it, or onto other buttons already in the palette. You can then click the palette to hide or show it. If you click away from the palette, it will be hidden.",
		"If you have more than 9 action buttons, you can use the scroll arrows to see all of the buttons present, and you can always drag buttons out of the palette whenever you want.",
		"You can drag action buttons anywhere on the screen, onto other buttons, or onto the little squares that appear when you start dragging them.",
		"If you drag a button onto another button, it'll snap onto that other button and form a little group.",
		"",  // empty space to force another br
		"If you need more help, check the wiki or send a mentorhelp."
	)

	to_chat(user, examine_block(explanation.Join("<br>")))

/obj/screen/action_palette/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

/obj/screen/action_palette/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	var/list/modifiers = params2list(params)
	// don't show the tooltip if we're dragging
	if(!LAZYACCESS(modifiers, DRAG) && !LAZYACCESS(modifiers, LEFT_CLICK))
		show_tooltip(params)

/obj/screen/action_palette/MouseExited()
	closeToolTip(usr)
	return ..()

GLOBAL_LIST_INIT(palette_added_matrix, list(0.4,0.5,0.2,0, 0,1.4,0,0, 0,0.4,0.6,0, 0,0,0,1, 0,0,0,0))
GLOBAL_LIST_INIT(palette_removed_matrix, list(1.4,0,0,0, 0.7,0.4,0,0, 0.4,0,0.6,0, 0,0,0,1, 0,0,0,0))

/obj/screen/action_palette/proc/play_item_added()
	color_for_now(GLOB.palette_added_matrix)

/obj/screen/action_palette/proc/play_item_removed()
	color_for_now(GLOB.palette_removed_matrix)

/obj/screen/action_palette/proc/color_for_now(list/new_color)
	if(color_timer_id)
		return
	color = new_color //We unfortunately cannot animate matrix colors. Curse you lummy it would be ~~non~~trivial to interpolate between the two valuessssssssss
	color_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_color), new_color), 2 SECONDS)

/obj/screen/action_palette/proc/remove_color(list/to_remove)
	color_timer_id = null
	color = null

/obj/screen/action_palette/proc/show_tooltip(params)
	openToolTip(usr, src, params, title = name, content = desc)

/obj/screen/action_palette/Click(location, control, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClick(usr)
		return TRUE

	if(LAZYACCESS(modifiers, ALT_CLICK))
		var/datum/hud/hud_used = usr.hud_used
		if(!istype(hud_used))
			to_chat(usr, SPAN_WARNING("You cannot reorganize actions without a HUD."))
			return TRUE // Prevent other actions

		var/button_number = 0
		for(var/datum/action/action as anything in usr.actions)
			button_number++
			action.button?.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
		return TRUE

	set_expanded(!expanded)

/obj/screen/action_palette/proc/clicked_while_open(datum/source, atom/target, atom/location, control, params, mob/user)
	if(istype(target, /obj/screen/movable/action_button) || istype(target, /obj/screen/palette_scroll) || target == src) // If you're clicking on an action button, or us, you can live
		return
	set_expanded(FALSE)
	if(source)
		UnregisterSignal(source, COMSIG_CLIENT_CLICK)

/obj/screen/action_palette/proc/set_expanded(new_expanded)
	var/datum/action_group/our_group = our_hud.palette_actions
	if(!LAZYLEN(our_group.actions))
		new_expanded = FALSE
		return
	if(expanded == new_expanded)
		return

	expanded = new_expanded
	our_group.refresh_actions()
	// update_appearance()

	if(!usr.client)
		return

	if(expanded)
		name = "Hide Buttons"
		RegisterSignal(usr.client, COMSIG_CLIENT_CLICK, PROC_REF(clicked_while_open))
	else
		name = "Show Buttons"
		UnregisterSignal(usr.client, COMSIG_CLIENT_CLICK)

	closeToolTip(usr) //Our tooltips are now invalid, can't seem to update them in one frame, so here, just close them

/obj/screen/palette_scroll
	/// How should we move the palette's actions?
	/// Positive scrolls down the list, negative scrolls back
	var/scroll_direction = 0
	var/datum/hud/our_hud

/obj/screen/palette_scroll/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

/obj/screen/palette_scroll/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

/obj/screen/palette_scroll/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	openToolTip(usr, src, params, title = name, content = desc)

/obj/screen/palette_scroll/Click(location, control, params)
	our_hud.palette_actions.scroll(scroll_direction)

/obj/screen/palette_scroll/MouseExited()
	closeToolTip(usr)
	return ..()

/obj/screen/palette_scroll/down
	name = "Scroll Down"
	desc = "<b>Click</b> on this to scroll the actions above down"
	icon_state = "scroll_down"
	scroll_direction = 1

/obj/screen/palette_scroll/down/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_down = null
		our_hud = null
	return ..()

/obj/screen/palette_scroll/up
	name = "Scroll Up"
	desc = "<b>Click</b> on this to scroll the actions above up"
	icon_state = "scroll_up"
	scroll_direction = -1

/obj/screen/palette_scroll/up/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_up = null
		our_hud = null
	return ..()

/// Exists so you have a place to put your buttons when you move them around
/obj/screen/action_landing
	name = "Button Space"
	desc = "<b>Drag and drop</b> a button into this spot<br>to add it to the group"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "reserved"
	// We want our whole 32x32 space to be clickable, so dropping's forgiving
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/action_group/owner

/obj/screen/action_landing/Destroy()
	if(owner)
		owner.landing = null
		owner?.owner?.mymob?.client?.screen -= src
		owner.refresh_actions()
		owner = null
	return ..()

/obj/screen/action_landing/proc/set_owner(datum/action_group/owner)
	src.owner = owner
	refresh_owner()

/obj/screen/action_landing/proc/refresh_owner()
	var/datum/hud/our_hud = owner.owner
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

/// Reacts to having a button dropped on it
/obj/screen/action_landing/proc/hit_by(obj/screen/movable/action_button/button)
	// var/datum/hud/our_hud = owner.owner
	// our_hud.position_action(button, owner.location)

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons()
	if(!hud_used)
		return
	if(!client)
		return

	for(var/datum/action/A in actions)
		if(A.button)
			client.screen -= A.button

	var/button_number = 0
	for(var/datum/action/A in actions)
		button_number++
		if(A.button == null)
			var/obj/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N

		var/obj/screen/movable/action_button/B = A.button

		B.UpdateIcon()

		B.name = A.name

		client.screen += B

		if(!B.moved)
			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)


#define AB_WEST_OFFSET 4
#define AB_NORTH_OFFSET 26
#define AB_MAX_COLUMNS 10

/datum/hud/proc/ButtonNumberToScreenCoords(var/number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = AB_WEST_OFFSET+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = AB_NORTH_OFFSET
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"

/datum/hud/proc/SetButtonCoords(var/obj/screen/button, var/number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + AB_WEST_OFFSET + 2*col
	var/y_offset = -32*(row+1) + AB_NORTH_OFFSET

	var/matrix/M = matrix()
	M.Translate(x_offset, y_offset)
	button.transform = M

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/CheckRemoval(mob/living/user)
	return !(target in user)

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

//Preset for general and toggled actions
/datum/action/innate
	check_flags = 0
	action_type = AB_INNATE

#undef AB_WEST_OFFSET
#undef AB_NORTH_OFFSET
#undef AB_MAX_COLUMNS
