extends RefCounted

var selected_item: StuffDie = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()

	e.set_image(load("res://assets/textures/event_icons/Ladder.png"))
	e.set_description("
		You see a ladder leading upward, and... Is that daylight?
		You've been down in these depths for so long, you can't be sure anymore.")
	e.add_option("
		Open the manhole and peek out, to make sure the coast is clear
		(Lose HP)")

	if selected_item != null:
		e.add_option("
			Open the manhole with your {item}, to avoid an ambush from whatever
			might be up there
			(Lose 1 item)"
		.format({ item = selected_item.name }))
	else:
		e.add_option("
			Try to open the manhole with whatever you can find
			(Lose 1 item if you had one)")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			Globals.player_stats.health = Globals.player_stats.health / 2
			# Globals.player_nav_event = "back"
			e.set_description("
				The way seems clear, and you climb up into... another sewer.
				It seems you've been down here too long after all. That definitely wasn't daylight.
				As your mind wanders, the manhole cover falls on your foot. Ow!")
		1:
			# Globals.player_nav_event = "back"
			if selected_item != null:
				Globals.player_stats.equipment.erase(selected_item)
				e.set_description("
					You carefully lift the manhole cover with your {item}, only to find that
					the way is clear. There was never any danger. The cover slips though,
					crushing your {item}. At least you've discovered a new path...
					Wait! This area feels eerily familiar."
				.format({ item = selected_item.name }))
			else:
				e.set_description("
					You try to find something to help lift the manhole cover, but there's nothing useful.
					You manage to push it open with your bare hands. The way is clear, and you climb up into...
					another sewer. This area feels eerily familiar.")

	e.add_option("Continue")

	await e.choice
