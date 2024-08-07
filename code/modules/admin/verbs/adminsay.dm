ADMIN_VERB_ADD(/client/proc/cmd_admin_say, R_ADMIN|R_MOD, TRUE)
//admin-only ooc chat
/client/proc/cmd_admin_say(msg as text)
	set category = "Admin.Special"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN|R_MOD))	return

	msg = sanitize(msg)
	if(!msg)	return

	log_admin("ADMIN: [key_name(src)] : [msg]")

	msg = emoji_parse(msg)

	if(check_rights(R_ADMIN,0))
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights)
				to_chat(C, "<span class='admin_channel'>" + create_text_tag("admin", "ADMIN:", C) + " <span class='name'>[key_name(usr, 1)]</span>([admin_jump_link(mob, src)]): <span class='message'>[msg]</span></span>")


ADMIN_VERB_ADD(/client/proc/cmd_mod_say, R_ADMIN|R_MOD|R_MENTOR|R_DEBUG, TRUE)
/client/proc/cmd_mod_say(msg as text)
	set category = "Admin.Special"
	set name = "Msay"
	set hidden = 1

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR|R_DEBUG))	return

	msg = sanitize(msg)
	log_admin("MOD: [key_name(src)] : [msg]")

	if (!msg)
		return

	var/sender_name = key_name(usr, 1)
	if(check_rights(R_ADMIN, 0))
		sender_name = "<span class='admin'>[sender_name]</span>"
	for(var/client/C in admins)
		to_chat(C, "<span class='mod_channel'>" + create_text_tag("mod", "MOD:", C) + " <span class='name'>[sender_name]</span>([admin_jump_link(mob, C.holder)]): <span class='message'>[msg]</span></span>")


