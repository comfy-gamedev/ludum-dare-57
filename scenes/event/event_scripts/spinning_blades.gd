extends RefCounted

var selected_item: StuffDie = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()

	e.set_image(load("res://assets/textures/event_icons/spinning fan.png"))
	e.set_description("
		The entire sewer tunnel is blocked here by some large spinning blades.
		Perhaps a fan or turbine of some sort?")
	e.add_option("
		The blades are spinning slow enough. You could try to jump through,
		if you time it just right.
		(Lose HP)")

	if selected_item != null:
		e.add_option("
			Jam the mechanism with your {item}. You didn't need that thing anyway, right?
			(Lose 1 item)"
		.format({ item = selected_item.name }))
	else:
		e.add_option("
			Try to jam the mechanism with whatever you can find
			(Lose 1 item if you had one)")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			Globals.player_stats.health = Globals.player_stats.health / 2
			# Globals.player_nav_event = "back"
			e.set_description("
				Oops! You did not time it just right. Well that hurt...
				At least the tunnel on the other side seems to lead somewhere useful.")
		1:
			# Globals.player_nav_event = "back"
			if selected_item != null:
				Globals.player_stats.equipment.erase(selected_item)
				e.set_description("
					You jam your {item} into the spinning motor and it grinds to a halt.
					It also grinds up your {item} until it's unrecognizable.
					The tunnel on the other side seems to lead somewhere familiar.
					Have you been here before?"
				.format({ item = selected_item.name }))
			else:
				e.set_description("
					You look around for something to jam into the spinning motor, but find nothing useful.
					You'll have to find another way around.")

	e.add_option("Continue")

	await e.choice
