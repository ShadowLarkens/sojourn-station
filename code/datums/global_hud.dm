/*
	The global hud:
	Uses the same visual objects for all players.
*/

// Initialized in ticker.dm, see proc/setup_huds()
var/datum/global_hud/global_hud
var/list/global_huds

/*
/datum/hud/var/obj/screen/grab_intent
/datum/hud/var/obj/screen/hurt_intent
/datum/hud/var/obj/screen/disarm_intent
/datum/hud/var/obj/screen/help_intent
*/
/datum/global_hud
	var/obj/screen/druggy
	var/obj/screen/blurry
	var/list/lightMask
	var/list/vimpaired
	var/list/darkMask
	var/obj/screen/nvg
	var/obj/screen/thermal
	var/obj/screen/meson
	var/obj/screen/science

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /obj/screen/fullscreen/tile("druggy")

	//that white blurry effect you get when you eyes are damaged
	blurry = new /obj/screen/fullscreen/tile("blurry")

	nvg = new /obj/screen/fullscreen("nvg_hud")
	//nvg.plane = LIGHTING_PLANE
	thermal = new /obj/screen/fullscreen("thermal_hud")
	meson = new /obj/screen/fullscreen("meson_hud")
	science = new /obj/screen/fullscreen("science_hud")

	//that nasty looking dither you  get when you're short-sighted
	lightMask = newlist(
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST,SOUTH to EAST,SOUTH+1"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST,SOUTH+2 to WEST+1,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST-1,SOUTH+2 to EAST,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+2,NORTH-1 to EAST-2,NORTH"},

		/obj/screen{icon_state = "dither50"; screen_loc = "WEST,SOUTH:-32 to EAST,SOUTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST:32,SOUTH to EAST,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST:32,SOUTH:-32"},
	)

	vimpaired = newlist(
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST,SOUTH to WEST+4,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+4,SOUTH to EAST-5,SOUTH+4"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+5,NORTH-4 to EAST-5,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST-4,SOUTH to EAST,NORTH"},

		/obj/screen{icon_state = "dither50"; screen_loc = "WEST,SOUTH:-32 to EAST,SOUTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST:32,SOUTH to EAST,NORTH"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST:32,SOUTH:-32"},
	)

	//welding mask overlay black/dither
	darkMask = newlist(
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+2,SOUTH+2 to WEST+4,NORTH-2"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+4,SOUTH+2 to EAST-5,SOUTH+4"},
		/obj/screen{icon_state = "dither50"; screen_loc = "WEST+5,NORTH-4 to EAST-5,NORTH-2"},
		/obj/screen{icon_state = "dither50"; screen_loc = "EAST-4,SOUTH+2 to EAST-2,NORTH-2"},

		/obj/screen{icon_state = "black"; screen_loc = "WEST,SOUTH to EAST,SOUTH+1"},
		/obj/screen{icon_state = "black"; screen_loc = "WEST,SOUTH+2 to WEST+1,NORTH"},
		/obj/screen{icon_state = "black"; screen_loc = "EAST-1,SOUTH+2 to EAST,NORTH"},
		/obj/screen{icon_state = "black"; screen_loc = "WEST+2,NORTH-1 to EAST-2,NORTH"},

		/obj/screen{icon_state = "black"; screen_loc = "WEST,SOUTH:-32 to EAST,SOUTH"},
		/obj/screen{icon_state = "black"; screen_loc = "EAST:32,SOUTH to EAST,NORTH"},
		/obj/screen{icon_state = "black"; screen_loc = "EAST:32,SOUTH:-32"},
	)

	for(var/obj/screen/O in (vimpaired + darkMask))
		O.layer = FULLSCREEN_LAYER
		O.plane = FULLSCREEN_PLANE
		O.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
