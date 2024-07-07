/mob/living/carbon/human/minimalize_HUD()
	var/datum/hud/human/human_hud = hud_used
	if(istype(human_hud))
		human_hud.minimalize_HUD(src)

/mob/living/carbon/human/update_hud()
	if(client)
		hud_used?.update_hud()
		// check_HUD()
		client.screen |= contents
		//if(hud_used)
			//hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar
	return

/mob/living/carbon/human/dead_HUD()
	for(var/p in hud_used?.HUDneed)
		var/obj/screen/H = hud_used.HUDneed[p]
		H.DEADelize()
