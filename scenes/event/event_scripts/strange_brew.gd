extends RefCounted

var selected_item: StuffDie = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()

	e.set_image(load("res://assets/textures/event_icons/Thermos.png"))
	e.set_description("
		You see a thermos sitting here. It seems to be filled with a thick, warm liquid.
		Could be delicious?")
	e.add_option("
		Take the thermos with you and drink as you keep walking
		(Lose a random item/relic)")
	e.add_option("
		Stop and drink the whole thing right here.
		(Gain 1 HP. Travel forward)")
	e.add_option("Leave it be.")
	
	var choice = await e.choice

	e.clear()

	match choice:
		0:
			Globals.player_stats.health = Globals.player_stats.max_health
			if not Globals.player_stats.equipment.is_empty():
				var eq: StuffDie = Globals.player_stats.equipment.pick_random()
				Globals.player_stats.equipment.erase(eq)
				e.set_description("
					As you're walking, a sewer worker catches you stealing their thermos.
					They demand your {name} from you in exchange."
				.format({ name = eq.name }))
			else:
				e.set_description("
					As you're walking, a sewer worker catches you stealing their thermos.
					They look at you with pity when they realize you have nothing to give them.")
		1:
			Globals.player_stats.health = Globals.player_stats.max_health
			# Globals.player_nav_event = "forward"
			e.set_description("
				You stop to enjoy the meal, and are caught off guard as a wave crashes through the sewer.
				You are washed 2 spaces downstream.")
		2:
			return

	e.add_option("Continue")

	await e.choice
