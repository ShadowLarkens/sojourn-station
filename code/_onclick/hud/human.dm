/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

//Used for new human mobs created by cloning/goleming/etc.
/mob/living/carbon/human/proc/set_cloned_appearance()
	f_style = "Shaved"
	if(dna.species == "Human") //no more xenos losing ears/tentacles
		h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	regenerate_icons()


/datum/hud/human

/datum/hud/human/show()
	. = ..()
	if(!.)
		return
	// Screen objects aren't positioned by default, have to call minimalize_HUD() 
	minimalize_HUD(mymob)

/datum/hud/human/update_hud()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = mymob

	var/recreate_flag = FALSE
	if(!check_HUDdatum(H))
		H.defaultHUD = "ErisStyle"
		recreate_flag = TRUE
	else if(H.client.prefs.UI_style != H.defaultHUD)
		H.defaultHUD = H.client.prefs.UI_style
		recreate_flag = TRUE

	if(recreate_flag)
		clear()
		create_HUD(H)

	show()
	minimalize_HUD(H)

	// recreate_flag is checked here because create_HUD will apply the correct color if it was called
	if(!recreate_flag && !check_HUD_style(H))//Check HUD colour
		recolor_HUD(H.client.prefs.UI_style_color, H.client.prefs.UI_style_alpha)

/// Used by species to force us to recreate our hud, since we depend on species
/datum/hud/human/force_recreate()
	. = ..()
	if(!.)
		return

	clear()
	create_HUD(mymob)
	show()
	minimalize_HUD(mymob)

/datum/hud/human/New(mob/living/carbon/human/owner)
	if(!istype(owner))
		CRASH("non-human [owner] tried to use a human hud")
	if(!owner.client)
		CRASH("[owner] tried to create a hud without a client")
	. = ..()
	
	if(!check_HUDdatum(owner))
		owner.defaultHUD = "ErisStyle"
	else if(owner.client.prefs.UI_style != owner.defaultHUD)
		owner.defaultHUD = owner.client.prefs.UI_style

	create_HUD(owner)

/datum/hud/human/proc/check_HUDdatum(mob/living/carbon/human/H)
	if(H.client.prefs.UI_style && !(H.client.prefs.UI_style == ""))
		if(GLOB.HUDdatums.Find(H.client.prefs.UI_style))
			return TRUE
	return FALSE

/datum/hud/human/proc/check_HUD_style(mob/living/carbon/human/H)
	for(var/obj/screen/inventory/HUDinv in HUDinventory)
		if(HUDinv.color != H.client.prefs.UI_style_color || HUDinv.alpha != H.client.prefs.UI_style_alpha)
			return FALSE

	for(var/p in HUDneed)
		var/obj/screen/HUDelm = HUDneed[p]
		if(HUDelm.color != H.client.prefs.UI_style_color || HUDelm.alpha != H.client.prefs.UI_style_alpha)
			return FALSE

/datum/hud/human/proc/create_HUD(mob/living/carbon/human/H)
	create_HUDinventory(H)
	create_HUDneed(H)
	create_HUDfrippery(H)
	create_HUDtech(H)
	recolor_HUD(H.client.prefs.UI_style_color, H.client.prefs.UI_style_alpha)

/datum/hud/human/proc/create_HUDinventory(mob/living/carbon/human/H)
	var/datum/hud_layout/human/HUDdatum = GLOB.HUDdatums[H.defaultHUD]

	for(var/gear_slot in H.species.hud.gear)//��������� �������� ���� (���������)
		if(!HUDdatum.slot_data.Find(gear_slot))
			log_debug("[usr] try take inventory data for [gear_slot], but HUDdatum not have it!")
			to_chat(H, "Sorry, but something went wrong with creating inventory slots, we recommend changing HUD type or call admins")
			return
		else
			var/HUDtype
			if(HUDdatum.slot_data[gear_slot]["type"])
				HUDtype = HUDdatum.slot_data[gear_slot]["type"]
			else
				HUDtype = /obj/screen/inventory

			var/obj/screen/inventory/inv_box = new HUDtype(
				gear_slot,
				H.species.hud.gear[gear_slot],
				HUDdatum.icon,
				HUDdatum.slot_data[gear_slot]["state"],
				H
			)

			if(HUDdatum.slot_data[gear_slot]["hideflag"])
				inv_box.hideflag = HUDdatum.slot_data[gear_slot]["hideflag"]

			HUDinventory += inv_box

/datum/hud/human/proc/create_HUDneed(mob/living/carbon/human/H)
	var/datum/hud_layout/human/HUDdatum = GLOB.HUDdatums[H.defaultHUD]

	for(var/HUDname in H.species.hud.ProcessHUD) //��������� �������� ���� (�� ���������)
		if(!HUDdatum.HUDneed.Find(HUDname)) //���� ����� � ������
			log_debug("[usr] try create a [HUDname], but it no have in HUDdatum [HUDdatum.name]")
		else
			var/HUDtype = HUDdatum.HUDneed[HUDname]["type"]

			var/obj/screen/HUD = new HUDtype(
				HUDname,
				H,
				HUDdatum.HUDneed[HUDname]["icon"] ? HUDdatum.HUDneed[HUDname]["icon"] : HUDdatum.icon,
				HUDdatum.HUDneed[HUDname]["icon_state"] ? HUDdatum.HUDneed[HUDname]["icon_state"] : null
			)

			if(HUDdatum.HUDneed[HUDname]["hideflag"])
				HUD.hideflag = HUDdatum.HUDneed[HUDname]["hideflag"]

			HUDneed[HUD.name] += HUD//��������� � ������ �����

			if(HUD.process_flag)//���� ��� ����� ����������
				HUDprocess += HUD//������� � �������������� ������

/datum/hud/human/proc/create_HUDfrippery(mob/living/carbon/human/H)
	var/datum/hud_layout/human/HUDdatum = GLOB.HUDdatums[H.defaultHUD]

	//��������� �������� ���� (���������)
	for(var/list/whistle in HUDdatum.HUDfrippery)
		var/obj/screen/frippery/F = new (whistle["icon_state"], whistle["loc"], H)
		F.icon = HUDdatum.icon
		if(whistle["hideflag"])
			F.hideflag = whistle["hideflag"]
		HUDfrippery += F

/datum/hud/human/proc/create_HUDtech(mob/living/carbon/human/H)
	var/datum/hud_layout/human/HUDdatum = GLOB.HUDdatums[H.defaultHUD]

	//��������� ����������� ��������(damage,flash,pain... �������)
	for(var/techobject in HUDdatum.HUDoverlays)
		var/HUDtype = HUDdatum.HUDoverlays[techobject]["type"]

		var/obj/screen/HUD = new HUDtype(
			techobject,
			H,
			HUDdatum.HUDoverlays[techobject]["icon"] ? HUDdatum.HUDoverlays[techobject]["icon"] : null,
		 	HUDdatum.HUDoverlays[techobject]["icon_state"] ? HUDdatum.HUDoverlays[techobject]["icon_state"] : null
		)
		HUD.layer = FLASH_LAYER

		HUDtech[HUD.name] += HUD//��������� � ������ �����
		if(HUD.process_flag)//���� ��� ����� ����������
			HUDprocess += HUD//������� � �������������� ������

/datum/hud/human/proc/minimalize_HUD(mob/living/carbon/human/H)
	var/datum/hud_layout/human/HUDdatum = GLOB.HUDdatums[H.defaultHUD]
	if(H.client.prefs.UI_compact_style && HUDdatum.MinStyleFlag)
		for(var/p in HUDneed)
			var/obj/screen/HUD = HUDneed[p]
			HUD.underlays.Cut()
			if(HUDdatum.HUDneed[p]["minloc"])
				HUD.screen_loc = HUDdatum.HUDneed[p]["minloc"]
			HUD.update_minimalized(TRUE)

		for(var/p in HUDtech)
			var/obj/screen/HUD = HUDtech[p]
			if(HUDdatum.HUDoverlays[p]["minloc"])
				HUD.screen_loc = HUDdatum.HUDoverlays[p]["minloc"]

		for(var/obj/screen/inventory/HUDinv in HUDinventory)
			HUDinv.underlays.Cut()
			for (var/p in H.species.hud.gear)
				if(H.species.hud.gear[p] == HUDinv.slot_id)
					if(HUDdatum.slot_data[p]["minloc"])
						HUDinv.screen_loc = HUDdatum.slot_data[p]["minloc"]
					break

		for(var/obj/screen/frippery/HUDfri in HUDfrippery)
			H.client.screen -= HUDfri

		winset(H, "mapwindow.status_bar", "size=270x16")
	else
		for(var/p in HUDneed)
			var/obj/screen/HUD = HUDneed[p]
			HUD.underlays.Cut()
			if(HUDdatum.HUDneed[p]["background"])
				HUD.underlays += HUDdatum.IconUnderlays[HUDdatum.HUDneed[p]["background"]]
			HUD.screen_loc = HUDdatum.HUDneed[p]["loc"]
			HUD.update_minimalized(FALSE)

		for(var/p in HUDtech)
			var/obj/screen/HUD = HUDtech[p]
			HUD.screen_loc = HUDdatum.HUDoverlays[p]["loc"]

		for(var/obj/screen/inventory/HUDinv in HUDinventory)
			for(var/p in H.species.hud.gear)
				if(H.species.hud.gear[p] == HUDinv.slot_id)
					HUDinv.underlays.Cut()
					if(HUDdatum.slot_data[p]["background"])//(HUDdatum.slot_data[HUDinv.slot_id]["background"])
						HUDinv.underlays += HUDdatum.IconUnderlays[HUDdatum.slot_data[p]["background"]]
					HUDinv.screen_loc = HUDdatum.slot_data[p]["loc"]
					break
		for(var/obj/screen/frippery/HUDfri in HUDfrippery)
			H.client.screen += HUDfri
		winset(H, "mapwindow.status_bar", "size=320x16")

	//update_equip_icon_position()
	for(var/obj/item/I in H.get_equipped_items(1))
		var/slotID = H.get_inventory_slot(I)
		I.screen_loc = H.find_inv_position(slotID)

	var/obj/item/I = H.get_active_hand()
	if(I)
		I.update_hud_actions()
	reorganize_alerts()
