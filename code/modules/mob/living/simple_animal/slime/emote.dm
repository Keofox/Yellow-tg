/mob/living/simple_animal/slime/emote(var/act)


	if (findtext(act, "~", 1, null))
		var/t1 = findtext(act, "~", 1, null)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/m_type = 1
	var/regenerate_icons
	var/message

	switch(act) //Alphabetical please
		if("bounce")
			message = "<B>The [src.name]</B> ������������ �� �����."
			m_type = 1

		if("jiggle")
			message = "<B>The [src.name]</B> �����������&#255;!"
			m_type = 1

		if("light")
			message = "<B>The [src.name]</B> ���������&#255; �� ���������, �� �����."
			m_type = 1

		if("moan")
			message = "<B>The [src.name]</B> ������."
			m_type = 2

		if("shiver")
			message = "<B>The [src.name]</B> ������."
			m_type = 2

		if("sway")
			message = "<B>The [src.name]</B> �������&#255;."
			m_type = 1

		if("twitch")
			message = "<B>The [src.name]</B> ��������&#255;."
			m_type = 1

		if("vibrate")
			message = "<B>The [src.name]</B> ���������!"
			m_type = 1

		if("noface") //mfw I have no face
			mood = null
			regenerate_icons = 1

		if("smile")
			mood = "mischevous"
			regenerate_icons = 1

		if(":3")
			mood = ":33"
			regenerate_icons = 1

		if("pout")
			mood = "pout"
			regenerate_icons = 1

		if("frown")
			mood = "sad"
			regenerate_icons = 1

		if("scowl")
			mood = "angry"
			regenerate_icons = 1

		if ("help") //This is an exception
			src << "������ ������ ��&#255; �������. �� ������ ������������ ��, ������ \"*emote\" � \"say\":\nbounce, jiggle, light, moan, shiver, sway, twitch, vibrate. \n\n�� ����� ������ �����&#255;�� ��� \"����������\": \n\nsmile, :3, pout, frown, scowl, noface"

		else
			src << "<span class='notice'>�������������&#255; �����&#255; '[act]'. �������� \"*help\" � \"say\" ��&#255; ������� ������.</span>"

	if ((message && stat == CONSCIOUS))
		if(client)
			log_emote("[ckey]/[name] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)

	if (regenerate_icons)
		regenerate_icons()

	return