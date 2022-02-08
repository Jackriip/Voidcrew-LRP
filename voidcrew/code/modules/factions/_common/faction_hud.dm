/datum/atom_hud/faction
	hud_icons = list(FACTION_HUD)
	var/self_visible = TRUE
	var/icon_color //will set the icon color to this

/datum/atom_hud/faction/hidden
	self_visible = FALSE

/datum/atom_hud/faction/proc/join_hud(mob/player)
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(player))
		CRASH("join_hud(): [player] ([player.type]) is not a mob!")
	if(player.mind.faction_hud) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting factionged
		player.mind.faction_hud.leave_hud(player)

	if(FACTION_HUD in player.hud_possible) //Current mob does not support faction huds ie newplayer
		add_to_hud(player)
		if(self_visible)
			add_hud_to(player)

	player.mind.faction_hud = src

/datum/atom_hud/faction/proc/leave_hud(mob/player)
	if(!player)
		return
	if(!istype(player))
		CRASH("leave_hud(): [player] ([player.type]) is not a mob!")
	remove_from_hud(player)
	remove_hud_from(player)
	if(player.mind)
		player.mind.faction_hud = null

//GAME_MODE PROCS
//called to set a mob's faction icon state
/proc/set_faction_hud(mob/player, new_icon_state, hudindex)
	if(!istype(player))
		CRASH("set_faction_hud(): [player] ([player.type]) is not a mob!")
	var/image/holder = player.hud_list[FACTION_HUD]
	var/datum/atom_hud/faction/specific_hud = hudindex ? GLOB.huds[hudindex] : null
	if(holder)
		holder.icon_state = new_icon_state
		holder.color = specific_hud?.icon_color
	if(player.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're factionging a mindless mob, meaning we should runtime
		player.mind.faction_hud_icon_state = new_icon_state


//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_faction_huds(datum/atom_hud/faction/newhud)
	leave_all_faction_huds()
	set_faction_hud(current, faction_hud_icon_state)
	if(newhud)
		newhud.join_hud(current)

/datum/mind/proc/leave_all_faction_huds()
	for(var/datum/atom_hud/faction/hud in GLOB.huds)
		if(hud.hudusers[current])
			hud.leave_hud(current)
