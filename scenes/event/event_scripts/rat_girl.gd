extends RefCounted

var gained_item: String = "nothing"

func run(e: EventScene) -> void:
	e.set_image(load("res://assets/textures/event_icons/rat_ambush.png"))
	e.set_description("
		You are walking along, when all of a sudden a Ratgirl jumps out of the shadows at you!")
	e.add_option("
		Stand your ground. Why should you be scared of a skinny little Ratgirl?
		(Lose health. Gain an item)")
	e.add_option("
		Run away. There's no point fighting when you could easily outrun her.
		(Move forward. Gain an item)")
	
	var choice = await e.choice
	
	e.clear()
	
	match choice:
		0:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.health /= 2
			e.set_description("
				You fend her off easily, but she does manage to bite you in the scuffle.
				Looks like she was carrying a {item}. It's yours now."
			.format({ item = gained_item }))
		1:
			gained_item = Globals.player_stats.add_equipment()
			# Globals.player_nav_event = "forward"
			e.set_description("
				You start jogging down the sewer when you realize she's faster than she looked.
				By the time you've lost her, you don't recognize where you are anymore.
				But you did stumble across a {item} just laying on the ground."
			.format({ item = gained_item }))
	
	e.add_option("Continue")
	
	await e.choice
