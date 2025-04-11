extends RefCounted

var selected_item: StuffDie = null
var selected_mutation: Mutation = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()
	
	if not Globals.player_stats.mutations.is_empty():
		selected_mutation = Globals.player_stats.mutations.pick_random()
	
	e.set_image(load("res://assets/textures/event_icons/clogged.png"))
	e.set_description("
		The water ahead keeps getting deeper and deeper, until it's no longer passable.
		The entire sewer pipe must be clogged in this direction.")
	
	if selected_item != null:
		e.add_option("
			Use your {item} to try to clear the blockage
			(Lose 1 item)"
		.format({ item = selected_item.name }))
	else:
		e.add_option("
			Try to clear the blockage with your bare hands
			(Lose 1 item if you had one)")
	
	e.add_option("
		Dive in and try to find a way around
		(Lose 1 mutation)")
	
	var choice = await e.choice
	
	e.clear()
	
	match choice:
		0:
			# Globals.player_nav_event = "back"
			if selected_item != null:
				Globals.player_stats.equipment.erase(selected_item)
				e.set_description("
					You stick your {item} in there and wiggle it around trying to break loose the blockage,
					but it's no use. Eventually your {item} gets stuck and you give up,
					doubling back to try to find another way around."
				.format({ item = selected_item.name }))
			else:
				e.set_description("
					You try to clear the blockage with your bare hands, but it's no use.
					You give up and double back to try to find another way around.")
		1:
			# Globals.player_nav_event = "back"
			if selected_mutation != null:
				Globals.player_stats.mutations.erase(selected_mutation)
				e.set_description("
					You d`ve in and eventually find a branch of the sewer that leads back up
					and off in another direction. The stagnant water seems to have reacted
					with your {mutation} mutation, causing it to reverse."
				.format({ mutation = selected_mutation.get_name() }))
			else:
				e.set_description("
					You dive in and eventually find a branch of the sewer that leads back up
					and off in another direction. Fortunately, you have no mutations to lose.")
	
	e.add_option("Continue")
	
	await e.choice
