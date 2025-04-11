extends RefCounted

var mutation: Mutation = null

func run(e: EventScene) -> void:
	if not Globals.player_stats.mutations.is_empty():
		mutation = Globals.player_stats.mutations.pick_random()
	
	e.set_description("
		[b]Event text[/b]")
	e.add_option("Lose 1 hp.")
	e.add_option("Lose 1 mutation.")
	if mutation == null:
		e.disable_option()
	
	var choice = await e.choice
	
	match choice:
		0:
			Globals.player_stats.health -= 1
		1:
			Globals.player_stats.mutations.erase(mutation)
	
	e.clear()
	e.set_description("Done.")
	e.add_option("Continue")
	
	await e.choice
