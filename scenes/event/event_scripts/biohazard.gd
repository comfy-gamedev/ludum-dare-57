extends RefCounted

var gained_mutation: String = "nothing"

func run(e: EventScene) -> void:
	e.set_image(load("res://assets/textures/event_icons/biohazard.png"))
	e.set_description("
		There's a pipe in the wall here, with a grubby \"biohazard\" sign on the wall.
		The sewage coming from the pipe seems to have a greenish glow.")
	e.add_option("
		Inspect the glowing water more closely
		(Lose HP. Gain a mutation)")
	e.add_option("
		Avoid the glowing water
		(Jump forward. Gain a mutation)")
	
	var choice = await e.choice
	
	e.clear()
	
	match choice:
		0:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.health = Globals.player_stats.health / 2
			e.set_description("
				You lean down to get a closer look at the glowing sewage. At this distance though,
				the smell hits you right in the face. As you recoil, you slip and bump your head,
				falling into the water. It burns, but you can feel yourself starting to mutate.")
		1:
			gained_mutation = Globals.player_stats.add_mutation()
			# Globals.player_nav_event = "forward"
			e.set_description("
				You walk down the path and realize this may be a shortcut, leading you even deeper
				into the sewer. After a while you get used to the smell of the glowing water,
				and realize that the fumes have begun to mutate you!")
	
	e.add_option("Continue")
	
	await e.choice
