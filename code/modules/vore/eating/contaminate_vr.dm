var/image/gurgled_overlay = image('icons/effects/sludgeoverlay_vr.dmi')

/obj/item
	var/gurgled = FALSE
	var/cleanname
	var/cleandesc

/obj/item/proc/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	if(!can_gurgle())
		return FALSE

	if(!gurgled)
		gurgled = TRUE
		overlays += gurgled_overlay
		var/gurgleflavor = pick("soggy","soaked","dirty","nasty","slimy","drenched","sloppy","grimy","sludgy","stinky","mucky","stained","soiled","filthy","saucy","foul","icky","tarnished","unsanitary","messy","begrimed","cruddy","funky","disgusting","repulsive","noxious","gruesome","gross","putrid","yucky","tainted","putrescent","unsavory","smelly","smutty","acrid","pungent","unclean","contaminated","gunky","gooey","sticky","drippy","oozing","sloshed","digested","sopping","damp","gloppy","begraggled","churned")
		cleanname = src.name
		cleandesc = src.desc
		name = "[gurgleflavor] [cleanname]"
		desc = "[cleandesc] It seems to be covered in ominously foul residue and needs a wash."
		for(var/obj/item/O in contents)
			gurgle_contaminate(internal_contents, item_storage)
		return TRUE

/obj/item/proc/can_gurgle()
	if(unacidable)
		return FALSE
	else
		return TRUE
/*
// Originally from Phoron.dm on vorestation's git.
/obj/item/proc/decontaminate()
	contaminated = 0
	overlays -= contamination_overlay
*/
/obj/item/proc/decontaminate() //Decontaminate the sogginess as well.
	return
/*	..()
	gurgled = FALSE
	overlays -= gurgled_overlay
	if(cleanname)
		name = cleanname
	if(cleandesc)
		desc = cleandesc*/


/obj/item/device/pda/can_use() //Get your rice bowl ready.
	if(gurgled)
		return FALSE
	else
		return ..()

/obj/structure/sink/attackby(obj/item/O as obj, mob/user as mob) //Wash the soggy item before it can interact with the sink.
	if(O.gurgled)
		var/turf/location = user.loc
		if(!isturf(location)) return

		var/obj/item/I = O
		if(!I || !istype(I,/obj/item)) return

		to_chat(usr, "<span class='notice'>You start washing \the [I].</span>")

		busy = TRUE
		sleep(40)
		busy = FALSE

		if(user.loc != location) return				//User has moved
		if(!I) return 								//Item's been destroyed while washing
		if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

		O.clean_blood()
		user.visible_message( \
			"<span class='notice'>[user] washes \a [I] using \the [src].</span>", \
			"<span class='notice'>You wash \a [I] using \the [src].</span>")
	else
		..()

//////////////
// Special things that happen when wet
//////////////
/obj/item/weapon/storage/box/open(mob/user as mob)
	if(gurgled)
		to_chat(usr,"The soggy box falls apart in your hands.")
		var/turf/T = get_turf(src)
		for(var/obj/item/I in contents)
			remove_from_storage(I, T)
		new/obj/effect/decal/cleanable/molten_item(T)
		qdel()
		return
	..()

// Because we dont have it defined in paradise's codebase, I'll define the item here, as it's only being used by this proc.

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"


//////////////
// Special handling of gurgle_contaminate
//////////////
/obj/item/weapon/card/id/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	digest_act(internal_contents, item_storage) //Digesting these anyway
	return TRUE

/obj/item/weapon/reagent_containers/food/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	digest_act(internal_contents, item_storage)
	return TRUE

/obj/item/weapon/holder/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	digest_act(internal_contents, item_storage)
	return TRUE

/obj/item/organ/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	digest_act(internal_contents, item_storage)
	return TRUE

/obj/item/weapon/cell/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	if(!gurgled)
	//Don't make them wet, just drain
		var/obj/item/weapon/stock_parts/cell/C = src
		C.charge = 0
	return TRUE

/obj/item/weapon/storage/box/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	if((. = ..()))
		name = "soggy [cleanname]"
		desc = "This soggy box is about to fall apart any time."

/obj/item/device/pda/gurgle_contaminate(var/list/internal_contents = null, var/atom/movable/item_storage = null)
	if((. = ..()))
		desc = "This device seems completely unresponsive while drenched with sludge. Perhaps you could still wash it."
