/obj/item/weapon/gun/hydrogen/pistol
	name = "\improper \"Classia\" hydrogen-plasma pistol"
	desc = "A volatile but powerful weapon that uses hydrogen flasks to fire destructive plasma bolts. The brain child of Soteria Director Nakharan Mkne, meant to compete and exceed the church of the absolutes \
	own plasma designs, it succeeded. However, it did so by being extremely dangerous, requiring an intelligent and careful operator who can correctly manage the weapons over heating without being \
	burnt to a crisp. This variant is a pistol, capable of fitting a holster for discrete travel and easy drawing."
	icon = 'icons/obj/guns/plasma/hydrogen.dmi'
	icon_state = "pistol"
	twohanded = FALSE
	w_class = ITEM_SIZE_NORMAL

	projectile_type = /obj/item/projectile/hydrogen/pistol
	use_plasma_cost = 10 // How much plasma is used per shot
	heat_per_shot = 25

	init_firemodes = list(
		list(mode_name = "standard", projectile_type = /obj/item/projectile/hydrogen/pistol, fire_sound = 'sound/weapons/lasercannonfire.ogg', fire_delay = 30, icon = "destroy", heat_per_shot = 25, use_plasma_cost = 10),
		list(mode_name = "overclock", projectile_type = /obj/item/projectile/hydrogen/pistol/max, fire_sound = 'sound/effects/supermatter.ogg', fire_delay = 50, icon = "kill", heat_per_shot = 40, use_plasma_cost = 20)
	)

/obj/item/weapon/gun/hydrogen/cannon
	name = "\improper \"Sollex\" hydrogen-plasma cannon"
	desc = "A volatile but powerful weapon that uses hydrogen flasks to fire destructive plasma bolts. The brain child of Soteria Director Nakharan Mkne, meant to compete and exceed the church of the absolutes \
	own plasma designs, it succeeded. However, it did so by being extremely dangerous, requiring an intelligent and careful operator who can correctly manage the weapons over heating without being \
	burnt to a crisp."
	icon = 'icons/obj/guns/plasma/hydrogen.dmi'
	icon_state = "cannon"

	projectile_type = /obj/item/projectile/hydrogen/cannon
	use_plasma_cost = 20 // How much plasma is used per shot
	heat_per_shot = 50

	init_firemodes = list(
		list(mode_name = "standard", projectile_type = /obj/item/projectile/hydrogen/cannon, fire_sound = 'sound/weapons/lasercannonfire.ogg', fire_delay = 30, icon = "destroy", heat_per_shot = 50, use_plasma_cost = 20),
		list(mode_name = "overclock", projectile_type = /obj/item/projectile/hydrogen/cannon/max, fire_sound = 'sound/effects/supermatter.ogg', fire_delay = 50, icon = "kill", heat_per_shot = 70, use_plasma_cost = 40)
	)

// Blue cross weapon, no overheat and infinite ammo.
/obj/item/weapon/gun/hydrogen/incinerator
	name = "\improper \"Reclaimator\" hydrogen-plasma gun"
	desc = "A bluecross weapon, this plasma gun doesn't seems to heat up and its hydrogen cell doesn't seem to run out"
	icon_state = "incinerator"
	use_plasma_cost = 0
	heat_per_shot = 0 // No heat gain.

	init_firemodes = list(
		list(mode_name = "standard", projectile_type = /obj/item/projectile/hydrogen, fire_sound = 'sound/weapons/lasercannonfire.ogg', fire_delay = 30, icon = "destroy", heat_per_shot = 0, use_plasma_cost = 1),
		list(mode_name = "overclock", projectile_type = /obj/item/projectile/hydrogen/max, fire_sound = 'sound/effects/supermatter.ogg', fire_delay = 50, icon = "kill", heat_per_shot = 0, use_plasma_cost = 1)
	)

/obj/item/weapon/gun/hydrogen/incinerator/Initialize()
	..()
	flask = new /obj/item/weapon/hydrogen_fuel_cell/infinite(src)

// Can't remove the cell
/obj/item/weapon/gun/hydrogen/incinerator/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	return
