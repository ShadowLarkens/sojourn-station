/mob/living/carbon/human/proc/handle_strip(slot_to_strip, mob/living/user)

	if(!slot_to_strip || !user.IsAdvancedToolUser())
		return

	if(user.incapacitated()  || !user.Adjacent(src))
		user << browse(null, text("window=mob[src.name]"))
		return

	var/obj/item/target_slot = get_equipped_item(text2num(slot_to_strip))

	switch(slot_to_strip)
		// Handle things that are part of this interface but not removing/replacing a given item.
		if("pockets")
			empty_pockets(user)
			return
		if("splints")
			remove_splints(user)
			return
		if("internals")
			toggle_internals(user)
			return
		if("tie")
			var/obj/item/clothing/under/suit = w_uniform
			if(!istype(suit) || !suit.accessories.len)
				return
			var/obj/item/clothing/accessory/A = suit.accessories[1]
			if(!istype(A))
				return
			visible_message(SPAN_DANGER("\The [usr] is trying to remove \the [src]'s [A.name]!"))

			if(!do_mob(user,src,HUMAN_STRIP_DELAY,progress=1))
				return

			if(!A || suit.loc != src || !(A in suit.accessories))
				return

			if(istype(A, /obj/item/clothing/accessory/badge) || istype(A, /obj/item/clothing/accessory/medal))
				user.visible_message(SPAN_DANGER("\The [user] tears off \the [A] from [src]'s [suit.name]!"))
			attack_log += "\[[time_stamp()]\] <font color='orange'>Has had \the [A] removed by [user.name] ([user.ckey])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [name]'s ([ckey]) [A.name]</font>"
			A.on_removed(user)
			suit.accessories -= A
			update_inv_w_uniform()
			return
		else
			var/obj/item/located_item = locate(slot_to_strip) in src
			if (istype(located_item, /obj/item/underwear))
				var/obj/item/underwear/UW = located_item
				visible_message(
					SPAN_DANGER("\The [user] starts trying to remove \the [src]'s [UW.name]!"),
					SPAN_WARNING("You start trying to remove \the [src]'s [UW.name]!")
				)
				if (UW.DelayedRemoveUnderwear(user, src))
					admin_attack_log(user, src, "Stripped \an [UW] from \the [src].", "Was stripped of \an [UW] from \the [src].", "stripped \an [UW] from \the [src] of")
					user.put_in_active_hand(UW)
				return

	// Are we placing or stripping?
	var/stripping
	var/obj/item/held = user.get_active_hand()
	if(!istype(held) || is_robot_module(held))
		if(!istype(target_slot))  // They aren't holding anything valid and there's nothing to remove, why are we even here?
			return
		if(!target_slot.canremove)
			to_chat(user, SPAN_WARNING("You cannot remove \the [src]'s [target_slot.name]."))
			return
		stripping = TRUE

	if(stripping)
		if((target_slot == r_hand || target_slot == l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to remove \the [src]'s [target_slot.name]."))
		else
			visible_message(SPAN_DANGER("\The [user] is trying to remove \the [src]'s [target_slot.name]!"))
	else
		if((slot_to_strip == r_hand || slot_to_strip == l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to put \a [held] on \the [src]."))
		else
			visible_message(SPAN_DANGER("\The [user] is trying to put \a [held] on \the [src]!"))

	if(!do_mob(user,src,HUMAN_STRIP_DELAY,progress = 1))
		return

	if(!stripping && user.get_active_hand() != held)
		return

	if(stripping)
		admin_attack_log(user, src, "Attempted to remove \a [target_slot]", "Target of an attempt to remove \a [target_slot].", "attempted to remove \a [target_slot] from")
		unEquip(target_slot)
		if(istype(target_slot,  /obj/item/storage/backpack))
			LEGACY_SEND_SIGNAL(user, COMSIG_EMPTY_POCKETS, src)
	else if(user.unEquip(held))
		equip_to_slot_if_possible(held, text2num(slot_to_strip), TRUE) // Disable warning
		if(held.loc != src)
			user.put_in_hands(held)

// Empty out everything in the target's pockets.
/mob/living/carbon/human/proc/empty_pockets(mob/living/user)
	if(!user.stats.getPerk(PERK_FAST_FINGERS))
		visible_message(SPAN_DANGER("\The [user] is trying to empty \the [src]'s pockets!"))
	else
		to_chat(user, SPAN_NOTICE("You silently try to empty \the [src]'s pockets."))
	if(!do_mob(user, src, HUMAN_STRIP_DELAY, progress = 1))
		return
	if(!r_store && !l_store)
		to_chat(user, SPAN_WARNING("\The [src] has nothing in their pockets."))
		return
	if(r_store)
		unEquip(r_store)
	if(l_store)
		unEquip(l_store)
	if(!user.stats.getPerk(PERK_FAST_FINGERS))
		visible_message(SPAN_DANGER("\The [user] empties \the [src]'s pockets!"))
	else
		to_chat(user, SPAN_NOTICE("You empty \the [src]'s pockets."))
	LEGACY_SEND_SIGNAL(user, COMSIG_EMPTY_POCKETS, src)

// Remove all splints.
/mob/living/carbon/human/proc/remove_splints(var/mob/living/user)
	visible_message(SPAN_DANGER("[user] is trying to remove [src]'s splints!"))
	if(!do_mob(user, src, HUMAN_STRIP_DELAY, progress = TRUE))
		return
	var/can_reach_splints = 1
	if(istype(wear_suit,/obj/item/clothing/suit/space))
		var/obj/item/clothing/suit/space/suit = wear_suit
		if(suit.supporting_limbs && suit.supporting_limbs.len)
			to_chat(user, SPAN_WARNING("You cannot remove the splints - [src]'s [suit] is in the way."))
			can_reach_splints = 0

	if(can_reach_splints)
		var/removed_splint
		for(var/organ in list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM, BP_CHEST, BP_GROIN, BP_HEAD))
			var/obj/item/organ/external/o = get_organ(organ)
			if (o && o.status & ORGAN_SPLINTED)
				var/obj/item/W = new /obj/item/stack/medical/splint(get_turf(src), 1)
				o.status &= ~ORGAN_SPLINTED
				W.add_fingerprint(user)
				removed_splint = 1
		if(removed_splint)
			visible_message(SPAN_DANGER("\The [user] removes \the [src]'s splints!"))
		else
			to_chat(user, SPAN_WARNING("\The [src] has no splints to remove."))

// Set internals on or off.
/mob/living/carbon/human/proc/toggle_internals(var/mob/living/user)
	visible_message(SPAN_DANGER("\The [usr] is trying to set \the [src]'s internals!"))
	if(!do_mob(user, src, HUMAN_STRIP_DELAY, progress = TRUE))
		return
	if(internal)
		visible_message(SPAN_DANGER("\The [user] disables \the [src]'s internals!"))
		internal.add_fingerprint(user)
		internal = null
	else
		// Check for airtight mask/helmet.
		if(!(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/helmet/space)))
			return
		// Find an internal source.
		if(istype(back, /obj/item/tank))
			internal = back
		else if(istype(s_store, /obj/item/tank))
			internal = s_store
		else if(istype(belt, /obj/item/tank))
			internal = belt
		visible_message(SPAN_WARNING("\The [src] is now running on internals!"))
		internal.add_fingerprint(user)

	if(HUDneed.Find("internal"))
		var/obj/screen/HUDelm = HUDneed["internal"]
		HUDelm.update_icon()

/mob/living/carbon/human/proc/strip_slot(mob/user, slot_id)
	var/obj/item/target_slot = get_equipped_item(slot_id)

	// Are we placing or stripping?
	var/stripping
	var/obj/item/held = user.get_active_hand()
	if(!istype(held) || is_robot_module(held))
		if(!istype(target_slot))  // They aren't holding anything valid and there's nothing to remove, why are we even here?
			return
		if(!target_slot.canremove)
			to_chat(user, SPAN_WARNING("You cannot remove [src]'s [target_slot]."))
			return
		stripping = TRUE

	if(stripping)
		if((slot_id == slot_r_hand || slot_id == slot_l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to remove [src]'s [target_slot]."))
		else
			visible_message(SPAN_DANGER("[user] is trying to remove [src]'s [target_slot]!"))
	else
		if((slot_id == slot_r_hand || slot_id == slot_l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to put \a [held] on [src]."))
		else
			visible_message(SPAN_DANGER("[user] is trying to put \a [held] on [src]!"))

	if(!do_mob(user, src, HUMAN_STRIP_DELAY, progress = TRUE))
		return

	if(!stripping && user.get_active_hand() != held)
		return

	if(stripping)
		admin_attack_log(user, src, "Attempted to remove \a [target_slot]", "Target of an attempt to remove \a [target_slot].", "attempted to remove \a [target_slot] from")
		unEquip(target_slot)
		if(istype(target_slot,  /obj/item/storage/backpack))
			LEGACY_SEND_SIGNAL(user, COMSIG_EMPTY_POCKETS, src)
	else if(user.unEquip(held))
		equip_to_slot_if_possible(held, slot_id, TRUE) // Disable warning
		if(held.loc != src)
			user.put_in_hands(held)

/mob/living/carbon/human/get_strip_panel_data(mob/user)
	var/list/data = list() // don't call ..()

	var/list/slots_data = list()
	for(var/entry in species.hud.gear)
		var/slot = species.hud.gear[entry]
		if(slot in list(slot_l_store, slot_r_store))
			continue
		var/obj/item/thing_in_slot = get_equipped_item(slot)
		var/thing = null
		var/appearance = null
		if(istype(thing_in_slot))
			thing = "[thing_in_slot]"
			if(length(thing_in_slot.overlays) > 2) // Icon is complex
				appearance = costly_icon2html(thing_in_slot, user, sourceonly = TRUE)
			else
				appearance = icon2html(thing_in_slot, user, sourceonly = TRUE)
		slots_data += list(list(
			"slot_name" = entry,
			"slot_id" = slot,
			"thing" = thing,
			"appearance" = appearance
		))
	// Special slot
	slots_data += list(list(
		"slot_name" = "Pockets",
		"slot_id" = slot_l_store,
		"thing" = null,
		"appearance" = null,
	))

	data["slots"] = slots_data

	var/list/special_actions = list()
	special_actions += list(list(
		"name" = "Remove Splints",
		"action" = "splints",
	))
	if(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/helmet/space))
		if(istype(back, /obj/item/tank) || istype(belt, /obj/item/tank) || istype(s_store, /obj/item/tank))
			special_actions += list(list(
				"name" = "Toggle internals",
				"action" = "toggle_internals",
				"selected" = internal != null
			))
	if(handcuffed)
		special_actions += list(list(
			"name" = "Remove Handcuffs",
			"action" = "strip",
			"params" = list("id" = slot_handcuffed),
		))
	if(legcuffed)
		special_actions += list(list(
			"name" = "Remove Legcuffs",
			"action" = "strip",
			"params" = list("id" = slot_legcuffed),
		))
	for(var/entry in worn_underwear)
		var/obj/item/underwear/UW = entry
		special_actions += list(list(
			"name" = "Remove [UW]",
			"action" = "remove_underwear",
			"params" = list("ref" = "\ref[UW]"),
		))
	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(LAZYLEN(U.accessories))
			special_actions += list(list(
				"name" = "Remove accessory",
				"action" = "accessory",
			))
	data["special_actions"] = special_actions

	return data

/mob/living/carbon/human/handle_stripping_actions(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("strip")
			var/slot_id = params["id"]
			if(slot_id == slot_l_store || slot_id == slot_r_store)
				empty_pockets(usr)
				return TRUE
			strip_slot(usr, slot_id)
			. = TRUE
		if("splints")
			remove_splints(usr)
			. = TRUE
		if("toggle_internals")
			toggle_internals(usr)
			. = TRUE
		if("remove_underwear")
			var/obj/item/located_item = locate(params["ref"]) in src
			if(istype(located_item, /obj/item/underwear))
				var/obj/item/underwear/UW = located_item
				visible_message(
					SPAN_DANGER("[usr] starts trying to remove [src]'s [UW.name]!"),
					SPAN_WARNING("You start trying to remove [src]'s [UW.name]!")
				)
				if(UW.DelayedRemoveUnderwear(usr, src))
					admin_attack_log(usr, src, "Stripped \an [UW] from [src].", "Was stripped of \an [UW] from [src].", "stripped \an [UW] from [src] of")
					usr.put_in_active_hand(UW)
			. = TRUE
		if("accessory")
			var/obj/item/clothing/under/suit = w_uniform
			if(!istype(suit) || !suit.accessories.len)
				return
			var/obj/item/clothing/accessory/A = suit.accessories[1]
			if(!istype(A))
				return
			visible_message(SPAN_DANGER("[usr] is trying to remove [src]'s [A.name]!"))

			if(!do_mob(usr, src, HUMAN_STRIP_DELAY, progress = TRUE))
				return

			if(!A || suit.loc != src || !(A in suit.accessories))
				return

			if(istype(A, /obj/item/clothing/accessory/badge) || istype(A, /obj/item/clothing/accessory/medal))
				usr.visible_message(SPAN_DANGER("[usr] tears off [A] from [src]'s [suit.name]!"))
			attack_log += "\[[time_stamp()]\] <font color='orange'>Has had [A] removed by [usr.name] ([usr.ckey])</font>"
			usr.attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [name]'s ([ckey]) [A.name]</font>"
			A.on_removed(usr)
			suit.accessories -= A
			update_inv_w_uniform()
			. = TRUE
