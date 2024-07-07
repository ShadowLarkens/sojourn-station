/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR|DEFAULT_APPEARANCE_FLAGS
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0

/obj/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/obj/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/obj/screen/plane_master/proc/backdrop(mob/mymob)

/obj/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER|DEFAULT_APPEARANCE_FLAGS
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER|DEFAULT_APPEARANCE_FLAGS //should use client color
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/game_world/backdrop(mob/mymob)
	filters = list()
	if(mymob.client && mymob.client.get_preference_value(/datum/client_preference/ambient_occlusion) == GLOB.PREF_YES)
		filters += AMBIENT_OCCLUSION

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
/*
/obj/screen/plane_master/lighting/backdrop(mob/mymob)
	mymob.overlay_fullscreen("lighting_backdrop_lit", /obj/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /obj/screen/fullscreen/lighting_backdrop/unlit)
*/
/*
/obj/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
*/
/obj/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE

/obj/screen/plane_master/open_space_plane
	name = "open space shadow plane"
	plane = OPENSPACE_PLANE

/datum/hud/proc/updatePlaneMasters(mob/viewmob, force = FALSE)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob || !screenmob.client)
		return

	var/atom/player = screenmob
	if(screenmob.client.virtual_eye)
		player = screenmob.client.virtual_eye

	var/turf/T = get_turf(player)
	if(!T)
		return

	var/z = T.z

	if(z == old_z && !force)
		return

	old_z = z

	var/datum/level_data/LD = z_levels[z]

	for(var/pmaster in plane_masters)
		var/obj/screen/plane_master/instance = plane_masters[pmaster]
		screenmob.client.screen -= instance
		qdel(instance)

	plane_masters.Cut()

	for(var/over in openspace_overlays)
		var/obj/screen/openspace_overlay/instance = openspace_overlays[over]
		screenmob.client.screen -= instance
		qdel(instance)

	openspace_overlays.Cut()

	if(!LD) return; //TODO: analyze why things can have no level here.

	for(var/zi in LD.original_level to z)
		var/relative_level = zi - LD.original_level + 1
		for(var/mytype in subtypesof(/obj/screen/plane_master))
			var/obj/screen/plane_master/instance = new mytype()

			instance.plane = calculate_plane(zi,instance.plane)

			plane_masters["[zi]-[relative_level]-[instance.plane]-[mytype]"] = instance
			screenmob.client.screen += instance
			instance.backdrop(screenmob)

		for(var/pl in list(GAME_PLANE,FLOOR_PLANE))
			if(zi < z)
				var/zdiff = z-(zi-1)

				var/obj/screen/openspace_overlay/oover = new
				oover.plane = calculate_plane(zi,pl)
				oover.alpha = min(255,zdiff*50 + 30)
				openspace_overlays["[zi]-[relative_level]-[oover.plane]"] = oover
				screenmob.client.screen += oover
