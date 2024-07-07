/datum/hud/robot

/datum/hud/robot/New(mob/living/silicon/robot/owner)
	if(!istype(owner))
		CRASH("non-robot [owner] tried to use a robot hud")
	if(!owner.client)
		CRASH("[owner] tried to create a hud without a client")
	. = ..()

	if(!check_HUDdatum(owner))
		owner.defaultHUD = "BorgStyle"

	create_HUD(owner)

/datum/hud/robot/proc/check_HUDdatum(mob/living/silicon/robot/H)
	if(H.defaultHUD == "BorgStyle") //���� � ������� ���� �������� �����\��� ����
		if(GLOB.HUDdatums.Find(H.defaultHUD))//���� ���������� ����� ��� ����
			return TRUE
	return FALSE

/datum/hud/robot/proc/create_HUD(mob/living/silicon/robot/H)
	create_HUDinventory(H)
	create_HUDneed(H)
	create_HUDfrippery(H)
	create_HUDtech(H)

/datum/hud/robot/proc/create_HUDinventory(mob/living/silicon/robot/H)
	var/datum/hud_layout/cyborg/HUDdatum = GLOB.HUDdatums[H.defaultHUD]
	for(var/HUDname in HUDdatum.slot_data)
		var/HUDtype = HUDdatum.slot_data[HUDname]["type"]

		var/obj/screen/silicon/inv_box = new HUDtype(
			HUDname,
			HUDdatum.slot_data[HUDname]["loc"],
			HUDdatum.slot_data[HUDname]["icon"] ? HUDdatum.slot_data[HUDname]["icon"] : HUDdatum.icon,
			HUDdatum.slot_data[HUDname]["icon_state"] ? HUDdatum.slot_data[HUDname]["icon_state"] : null,
			H,
			HUDdatum.slot_data.Find(HUDname)
		)

		HUDinventory += inv_box

/datum/hud/robot/proc/create_HUDneed(mob/living/silicon/robot/H)
	var/datum/hud_layout/cyborg/HUDdatum = GLOB.HUDdatums[H.defaultHUD]
	for(var/HUDname in HUDdatum.HUDneed)
		var/HUDtype = HUDdatum.HUDneed[HUDname]["type"]

		var/obj/screen/HUD = new HUDtype(
			HUDname,
			H,
			HUDdatum.HUDneed[HUDname]["icon"] ? HUDdatum.HUDneed[HUDname]["icon"] : HUDdatum.icon,
			HUDdatum.HUDneed[HUDname]["icon_state"] ? HUDdatum.HUDneed[HUDname]["icon_state"] : null
		)

		HUD.screen_loc = HUDdatum.HUDneed[HUDname]["loc"]
		HUDneed[HUD.name] += HUD//��������� � ������ �����
		if(HUD.process_flag)//���� ��� ����� ����������
			HUDprocess += HUD//������� � �������������� ������

/datum/hud/robot/proc/create_HUDfrippery(mob/living/silicon/robot/H)
	var/datum/hud_layout/cyborg/HUDdatum = GLOB.HUDdatums[H.defaultHUD]
	//��������� �������� ���� (���������)
	for(var/list/whistle in HUDdatum.HUDfrippery)
		var/obj/screen/frippery/F = new(whistle["icon_state"], whistle["loc"], whistle["dir"], H)
		F.icon = HUDdatum.icon
		HUDfrippery += F

/datum/hud/robot/proc/create_HUDtech(mob/living/silicon/robot/H)
	var/datum/hud_layout/cyborg/HUDdatum = GLOB.HUDdatums[H.defaultHUD]
	//��������� ����������� ��������(damage,flash,pain... �������)
	for(var/techobject in HUDdatum.HUDoverlays)
		var/HUDtype = HUDdatum.HUDoverlays[techobject]["type"]
		var/obj/screen/HUD = new HUDtype(_name = techobject, _parentmob = H)

		if(HUDdatum.HUDoverlays[techobject]["icon"])//������ �� �������� icon
			HUD.icon = HUDdatum.HUDoverlays[techobject]["icon"]
		else
			HUD.icon = HUDdatum.icon

		if(HUDdatum.HUDoverlays[techobject]["icon_state"])//������ �� �������� icon_state
			HUD.icon_state = HUDdatum.HUDoverlays[techobject]["icon_state"]

		HUDtech[HUD.name] += HUD//��������� � ������ �����
		if (HUD.process_flag)//���� ��� ����� ����������
			HUDprocess += HUD//������� � �������������� ������
