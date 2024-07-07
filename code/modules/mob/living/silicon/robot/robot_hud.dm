/mob/living/silicon/robot/update_hud()
	hud_used?.update_hud()

/mob/living/silicon/robot/proc/toggle_show_robot_modules()
	if(!isrobot(src))
		return

	var/mob/living/silicon/robot/r = src

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()


/mob/living/silicon/robot/proc/update_robot_modules_display()
	if(!isrobot(src))
		return

	var/mob/living/silicon/robot/r = src

	if(r.shown_robot_modules)
		//Modules display is shown
		//r.client.screen += robot_inventory	//"store" icon

		if(!r.module)
			to_chat(usr, SPAN_DANGER("No module selected"))
			return

		if(!r.module.modules)
			to_chat(usr, SPAN_DANGER("Selected module has no modules to select"))
			return

		if(!r.robot_modules_background)
			return

		var/display_rows = -round(-(r.module.modules.len) / 8)
		r.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately adding the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(r.HasTrait(CYBORG_TRAIT_EMAGGED) && !has_given_emaged_gifts)
			if(!(r.module.emag in r.module.modules))
				to_chat(src, SPAN_DANGER("More modules unlocked!"))
				r.module.modules.Add(r.module.emag)
				has_given_emaged_gifts = TRUE
		else
			if(r.module.emag in r.module.modules)
				to_chat(src, SPAN_DANGER("Some modules have been locked!"))
				r.module.modules.Remove(r.module.emag)
				has_given_emaged_gifts = FALSE

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
				A.layer = 20

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		//r.client.screen -= robot_inventory	//"store" icon
		for(var/atom/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen -= A
		r.shown_robot_modules = 0
		r.client.screen -= r.robot_modules_background
