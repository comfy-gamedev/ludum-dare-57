extends RefCounted

var selected_mutation: Mutation = null
var gained_item: String = "nothing"

func run(e: EventScene) -> void:
	if not Globals.player_stats.mutations.is_empty():
		selected_mutation = Globals.player_stats.mutations.pick_random()

	e.set_image(load("res://assets/textures/event_icons/Slimy Log.png"))
	e.set_description("
		There's a big, slimy-looking log over here.
		It looks like there might be something under it.")
	e.add_option("
		Roll the log forward to see what's under it
		(Lose HP. Gain an item)")
	e.add_option("
		Roll the log backward to see what's under it
		(Lose 1 mutation. Gain an item)")
	e.add_option("Skip.")
	
	var choice = await e.choice
	
	e.clear()

	match choice:
		0:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.health = Globals.player_stats.health / 2
			e.set_description("
				Oops! There was a centipede under there. It doesn't seem happy to have a visitor
				and gives you a painful bite. At least you found a {item}."
			.format({ item = gained_item }))
		1:
			gained_item = Globals.player_stats.add_equipment()
			if not Globals.player_stats.mutations.is_empty():
				var mut: Mutation = Globals.player_stats.mutations.pick_random()
				Globals.player_stats.mutations.erase(mut)
				e.set_description("
					You wisely roll the log backward. An angry centipede jumps out from under the log,
					away from you. You've discovered a {item}! The slime seems to have reacted with your skin
					however, neutralizing your {mutation} mutation."
				.format({ item = gained_item, mutation = mut.get_name() }))
			else:
				e.set_description("
					You wisely roll the log backward. An angry centipede jumps out from under the log,
					away from you. You've discovered a {item}! The slime seems to have reacted with your skin,
					but you have no mutations to lose."
				.format({ item = gained_item }))
		2:
			return

	e.add_option("Continue")

	await e.choice
