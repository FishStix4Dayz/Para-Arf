/obj/item/weapon/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/hypo.dmi'
	item_state = "syringe_0"
	icon_state = "lepopen"
	var/used = null

	update_icon()
		if(used)
			icon_state = "lepopen0"
		else
			icon_state = "lepopen"

	attack(mob/M as mob, mob/user as mob)
		if(!M || !user)
			return

		if(!ishuman(M) || !ishuman(user))
			return

		if(used)
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(NO_DNA in H.species.species_traits)
				to_chat(user, "<span class='warning'>You failed to inject [M], as they have no DNA to scramble, nor flesh to inject.</span>")
				return

		if(M == user)
			user.visible_message("<span class='danger'>[user] injects \himself with [src]!</span>")
			injected(user, user)
		else
			user.visible_message("<span class='danger'>[user] is trying to inject [M] with [src]!</span>")
			if(do_mob(user,M,30))
				user.visible_message("<span class='danger'>[user] injects [M] with [src].</span>")
				injected(M, user)
			else
				to_chat(user, "<span class='warning'>You failed to inject [M].</span>")

	proc/injected(var/mob/living/carbon/human/target, var/mob/living/carbon/user)
		if(istype(target))
			var/mob/living/carbon/human/H = target
			scramble(1, H, 100)
			H.real_name = random_name(H.gender, H.species.name) //Give them a name that makes sense for their species.
			H.sync_organ_dna(assimilate = 1)
			H.update_body(0)
			H.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
			H.reset_markings() //...Or markings.
			H.dna.ResetUIFrom(H)
		target.update_icons()

		log_attack("[key_name(user)] injected [key_name(target)] with the [name]")
		log_game("[key_name_admin(user)] injected [key_name_admin(target)] with the [name]")

		used = 1
		update_icon()
		name = "used " + name
