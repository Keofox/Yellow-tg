/mob/living/carbon/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/carbon/proc/prepare_data_huds()
	..()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/carbon/updatehealth()
	..()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/carbon/Destroy()
	for(var/atom/movable/guts in internal_organs)
		qdel(guts)
	for(var/atom/movable/food in stomach_contents)
		qdel(food)
	remove_from_all_data_huds()
	return ..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2

/mob/living/carbon/movement_delay()
	. = 0
	if(legcuffed)
		. += legcuffed.slowdown

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			audible_message("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>", \
						 "<span class='warning'>You hear something rumbling.</span>", 4,\
						  "<span class='userdanger'>Something is rumbling inside your stomach!</span>")
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ("chest")
					if (istype(organ, /obj/item/organ/limb))
						var/obj/item/organ/limb/temp = organ
						if(temp.take_damage(d, 0))
							H.update_damage_overlays(0)
					H.updatehealth()
				else
					src.take_organ_damage(d)
				visible_message("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>", \
									"<span class='userdanger'>[user] attacks your stomach wall with the [I.name]!</span>")
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/gib(var/animation = 1)
	for(var/mob/M in src)
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.loc = loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
	. = ..()


/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0
	src.take_overall_damage(0,shock_damage)
	//src.burn_skin(shock_damage)
	//src.adjustFireLoss(shock_damage) //burn_skin will do this for us
	//src.updatehealth()
	src.visible_message(
		"<span class='danger'>[src] ������� �����!</span>", \
		"<span class='userdanger'>�� ���� ����� ���������� ������ ������������� ����!</span>", \
		"<span class='italics'>�� ������� ������� ������������� �����.</span>" \
	)
	if(prob(25) && heart_attack)
		heart_attack = 0
	jitteriness += 1000 //High numbers for violent convulsions
	do_jitter_animation(jitteriness)
	stuttering += 2
	Stun(2)
	spawn(20)
		src.jitteriness -= 990 //Still jittery, but vastly less
		Stun(3)
		Weaken(3)
	return shock_damage


/mob/living/carbon/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/weapon/twohanded))
			if(item_in_hand:wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>"
				return
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode() // Activate held item

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= 0)

		if(lying)
			sleeping = max(0, sleeping - 5)
			if(sleeping == 0)
				resting = 0
			M.visible_message("<span class='notice'>[M] ��&#255;��� [src], ����&#255;�� �������� [src.gender=="male"?"���":"�"] � �������!</span>", \
							"<span class='notice'>�� ��&#255;���� [src], ����&#255;�� �������� [src.gender=="male"?"���":"�"] � �������!</span>")
		else
			M.visible_message("<span class='notice'>[M] �������� [src], ����� [src.gender=="male"?"���":"��"] ����� �����!</span>", \
						"<span class='notice'>�� ��������� [src], ����� [src.gender=="male"?"���":"��"] ����� �����!</span>")

		AdjustParalysis(-3)
		AdjustStunned(-3)
		AdjustWeakened(-3)

		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0)
	var/damage = intensity - check_eye_prot()
	if(..()) // we've been flashed
		if(weakeyes)
			Stun(2)
		switch(damage)
			if(1)
				src << "<span class='warning'>���� ����� ������ ��������.</span>"
				if(prob(40))
					eye_stat += 1

			if(2)
				src << "<span class='warning'>���� ����� ������� &#255;���� ������.</span>"
				eye_stat += rand(2, 4)

			else
				src << "<span class='warning'>�� ���������� ������ ���� � ������!</span>"
				eye_stat += rand(12, 16)

		if(eye_stat > 10)
			eye_blind += damage
			eye_blurry += damage * rand(3, 6)

			if(eye_stat > 20)
				if (prob(eye_stat - 20))
					src << "<span class='warning'>���� ����� ��������� ���&#255;� �� ����!</span>"
					disabilities |= NEARSIGHT
				else if(prob(eye_stat - 25))
					src << "<span class='warning'>�� ������ �� ������!</span>"
					disabilities |= BLIND
			else
				src << "<span class='warning'>����� ������ ����� ������������� ������. ��� ����� ������� �� �������&#255;!</span>"
		return 1

	else if(damage == 0) // just enough protection
		if(prob(20))
			src << "<span class='notice'>����� ����� �� �������� &#255;���� �������.</span>"

/mob/living/carbon/proc/eyecheck()
	var/obj/item/cybernetic_implant/eyes/EFP = locate() in src
	if(EFP)
		return EFP.flash_protect
	return 0

/mob/living/carbon/proc/tintcheck()
	return 0

/mob/living/carbon/clean_blood()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
		else
			..() // Clear the Blood_DNA list
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.bloody_hands_mob = null
				H.update_inv_gloves(0)
	update_icons()	//apply the now updated overlays to the mob



//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = 0
	throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = 1
	throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen)) return

	var/atom/movable/item = src.get_active_hand()

	if(!item || (item.flags & NODROP)) return

	if(istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throws() //throw the person instead of the grab
		qdel(G)			//We delete the grab, as it needs to stay around until it's returned.
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				add_logs(src, M, "thrown", admin=0, addition="from [start_T_descriptor] with the target [end_T_descriptor]")

	if(!item) return //Grab processing has a chance of returning null

	if(!ismob(item)) //Honk mobs don't have a dropped() proc honk
		unEquip(item)
	if(src.client)
		src.client.screen -= item

	//actually throw it!
	if(item)
		item.layer = initial(item.layer)
		src.visible_message("<span class='danger'>[src] ������[src.gender=="male"?"":"�"] [item].</span>")

		newtonian_move(get_dir(target, src))

		item.throw_at(target, item.throw_range, item.throw_speed)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/proc/canBeHandcuffed()
	return 0


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>				[(head && !(head.flags&ABSTRACT)) 			? head 		: "Nothing"]</A>
	<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>		[(wear_mask && !(wear_mask.flags&ABSTRACT))	? wear_mask	: "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[slot_l_hand]'>		[(l_hand && !(l_hand.flags&ABSTRACT))		? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[slot_r_hand]'>		[(r_hand && !(r_hand.flags&ABSTRACT))		? r_hand	: "Nothing"]</A>"}

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'> [back ? back : "Nothing"]</A>"

	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank))
		dat += "<BR><A href='?src=\ref[src];internal=1'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	if(handcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_handcuffed]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	user << browse(dat, "window=mob\ref[src];size=325x500")
	onclose(user, "mob\ref[src]")

/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["internal"])
			var/slot = text2num(href_list["internal"])
			var/obj/item/ITEM = get_item_by_slot(slot)
			if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
				visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>")
				if(do_mob(usr, src, POCKET_STRIP_DELAY))
					if(internal)
						internal = null
						if(internals)
							internals.icon_state = "internal0"
					else if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
						internal = ITEM
						if(internals)
							internals.icon_state = "internal1"

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>")



/mob/living/carbon/getTrail()
	if(getBruteLoss() < 300)
		if(prob(50))
			return "ltrails_1"
		return "ltrails_2"
	else if(prob(50))
		return "trails_1"
	return "trails_2"

var/const/NO_SLIP_WHEN_WALKING = 1
var/const/STEP = 2
var/const/SLIDE = 4
var/const/GALOSHES_DONT_HELP = 8
/mob/living/carbon/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	loc.handle_slip(src, s_amount, w_amount, O, lube)

/mob/living/carbon/fall(var/forced)
    loc.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))


/mob/living/carbon/revive()
	heart_attack = 0
	..()
	return

/mob/living/carbon/blob_act()
	if (stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>The blob attacks!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/proc/spin(spintime, speed)
	spawn()
		var/D = dir
		while(spintime >= speed)
			sleep(speed)
			switch(D)
				if(NORTH)
					D = EAST
				if(SOUTH)
					D = WEST
				if(EAST)
					D = SOUTH
				if(WEST)
					D = NORTH
			dir = D
			spintime -= speed
	return

/mob/living/carbon/resist_buckle()
	if(handcuffed)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		visible_message("<span class='warning'>[src] �������&#255; �����������&#255;!</span>", \
					"<span class='notice'>�� ��������� �����������&#255;... (��� ������ ����� ������, �� ����������.)</span>")
		if(do_after(src, 600, needhand = 0))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src,src)
		else
			if(src && buckled)
				src << "<span class='warning'>� ��� �� ���������� �����������&#255;!</span>"
	else
		buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	fire_stacks -= 5
	Weaken(3,1)
	spin(32,2)
	visible_message("<span class='danger'>[src] �������&#255; �� ����, ����&#255;�� ����� � ���&#255; �����!</span>", \
		"<span class='notice'>�� ����&#255;���� �������&#255; �� ����!</span>")
	sleep(30)
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src] ������� ������� ���&#255;!</span>", \
			"<span class='notice'>�� ������ �������� ���� ���.</span>")
		ExtinguishMob()
	return

/mob/living/carbon/resist_restraints()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(I)


/mob/living/carbon/proc/cuff_resist(obj/item/I, var/breakouttime = 600, cuff_break = 0)
	if(istype(I, /obj/item/weapon/restraints))
		var/obj/item/weapon/restraints/R = I
		breakouttime = R.breakouttime
	var/displaytime = breakouttime / 600
	if(!cuff_break)
		visible_message("<span class='warning'>[src] �������&#255; ��&#255;�� [I]!</span>")
		src << "<span class='notice'>�� ��������� ��&#255;�� [I]... (��� ������ ����� [displaytime] �����, �� ����������.)</span>"
		if(do_after(src, breakouttime, 10, 0))
			if(I.loc != src || buckled)
				return
			visible_message("<span class='danger'>[src] �����[src.gender=="male"?"":"�"] ��&#255;�� � ���&#255; [I]!</span>")
			src << "<span class='notice'>�� ������� ��&#255;�� � ���&#255; [I].</span>"

			if(handcuffed)
				handcuffed.loc = loc
				handcuffed.dropped(src)
				handcuffed = null
				if(buckled && buckled.buckle_requires_restraints)
					buckled.unbuckle_mob()
				update_inv_handcuffed(0)
				return
			if(legcuffed)
				legcuffed.loc = loc
				legcuffed = null
				update_inv_legcuffed(0)
		else
			src << "<span class='warning'>� ��� �� ����� ��&#255;�� [I]!</span>"

	else
		breakouttime = 50
		visible_message("<span class='warning'>[src] �������&#255; ������� [I]!</span>")
		src << "<span class='notice'>�� ��������� ������� [I]... (��� ������ ����� 5 ������, �� ����������.)</span>"
		if(do_after(src, breakouttime, needhand = 0))
			if(!I.loc || buckled)
				return
			visible_message("<span class='danger'>[src] �����[src.gender=="male"?"":"�"] ������� [I]!</span>")
			src << "<span class='notice'>�� ������ ������� [I].</span>"
			qdel(I)

			if(handcuffed)
				handcuffed = null
				update_inv_handcuffed(0)
				return
			else
				legcuffed = null
				update_inv_legcuffed(0)
		else
			src << "<span class='warning'>� ��� �� ����� ������� [I]!</span>"

/mob/living/carbon/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	if( (!mask_only && head && (head.flags & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)) )
		return 1

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	if(lying)
		return -6
	else
		return initial(pixel_y)

/mob/living/carbon/check_ear_prot()
	if(head && (head.flags & HEADBANGPROTECT))
		return 1
