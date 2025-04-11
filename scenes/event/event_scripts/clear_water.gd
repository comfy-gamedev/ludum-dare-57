extends RefCounted

var mutation: Mutation = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.mutations.is_empty():
		mutation = Globals.player_stats.mutations.pick_random()

	e.set_image(load("res://assets/textures/event_icons/clear_water_pool.png"))
	e.set_description("
		The sewer makes a turn here, and there's a section of water that's remarkably clean and clear.
		Now would be a great time to rinse off and dress some of your wounds.")
	e.add_option("
		Take off your equipment before jumping in.
		(Gain 1 HP. Lose a random item.)")
	e.add_option("
		Just jump in. Don't want to lose your precious stuff!
		(Gain 1 HP. Lose a random mutation.)")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			Globals.player_stats.health = Globals.player_stats.max_health
			if not Globals.player_stats.equipment.is_empty():
				var eq: StuffDie = Globals.player_stats.equipment.pick_random()
				Globals.player_stats.equipment.erase(eq)
				e.set_description("
					The cool water refreshes you, but when you leave the pool,
					you find your {name} is missing."
				.format({ name = eq.name }))
			else:
				e.set_description("
					The cool water refreshes you, and you feel as though the material world is merely an illusion.
					[i][color=red]You begin to notice the dream...[/color][/i]")
		1:
			Globals.player_stats.health = Globals.player_stats.max_health
			if not Globals.player_stats.mutations.is_empty():
				var eq: Mutation = Globals.player_stats.mutations.pick_random()
				Globals.player_stats.mutations.erase(eq)
				e.set_description("
					You feel cleaner and more refreshed after a dip in the pool.
					The water purifies you, and your {name} disappears.
					You feel slightly more human again."
				.format({ name = eq.get_name() }))
			else:
				e.set_description("
					The cool water refreshes you, and you sense the conviction of your humanity.
					[i][color=red]Your ego strengthens...[/color][/i]")

	e.add_option("Continue")

	await e.choice
