extends RefCounted

var selected_mutation: Mutation = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.mutations.is_empty():
		selected_mutation = Globals.player_stats.mutations.pick_random()

	e.set_image(load("res://assets/textures/event_icons/Pipe side tunnel.png"))
	e.set_description("
		You see a side tunnel, and it feels strangely warm.
		This could be a good place to stop and rest.")
	e.add_option("
		Play it safe and stay awake while you rest
		(Gain 1 HP. Lose 1 mutation)")
	e.add_option("
		Lay down and take a quick nap
		(Gain 1 HP. Jump ahead)")
	e.add_option("Press on.")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			Globals.player_stats.health = Globals.player_stats.max_health
			if not Globals.player_stats.mutations.is_empty():
				var mut: Mutation = Globals.player_stats.mutations.pick_random()
				Globals.player_stats.mutations.erase(mut)
				e.set_description("
					As you rest, you start to see strange visions... too late you realize the fumes
					from this tunnel are making you hallucinate. By the time you get up, you notice
					that your {name} mutation is gone!"
				.format({ name = mut.get_name() }))
			else:
				e.set_description("
					As you rest, you start to see strange visions... too late you realize the fumes
					from this tunnel are making you hallucinate. Fortunately, you have no mutations
					to lose.")
		1:
			Globals.player_stats.health = Globals.player_stats.max_health
			# Globals.player_nav_event = "forward"
			e.set_description("
				You fall asleep easily, having wild and vivid dreams.
				When you wake, you realize you have moved deeper into the sewer somehow.")
		2:
			return

	e.add_option("Continue")

	await e.choice
