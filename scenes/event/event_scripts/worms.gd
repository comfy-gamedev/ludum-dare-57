extends RefCounted

var selected_item: StuffDie = null
var gained_mutation: String = "nothing"

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()

	e.set_image(load("res://assets/textures/event_icons/worms.png"))
	e.set_description("
		The water here is almost knee-deep, which is why you didn't notice that swarm
		of purplish worm creatures until just now, as they start biting you.")
	e.add_option("
		Back away and cut open the wound to try to remove the poison
		(Lose HP. Gain a mutation)")

	if selected_item != null:
		e.add_option("
			Fend off the creatures with your {item}
			(Lose 1 item. Gain a mutation)"
		.format({ item = selected_item.name }))
	else:
		e.add_option("
			Fend off the creatures with your bare hands
			(Lose 1 item if you had one. Gain a mutation)")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.health = Globals.player_stats.health / 2
			e.set_description("
				Fortunately, the \"poison\" seems to have only given you a new mutation.
				Unfortunately, you were a little overzealous in trying to remove the poison.
				That cut looks like it might be infected...")
		1:
			gained_mutation = Globals.player_stats.add_mutation()
			if selected_item != null:
				Globals.player_stats.equipment.erase(selected_item)
				e.set_description("
					You try to fend off the worms with your {item}, but they manage to wrench it
					out of your grip. After that, they quickly lose interest in you. Unfortunately,
					in this murky water, you're never getting that {item} back."
				.format({ item = selected_item.name }))
			else:
				e.set_description("
					You try to fend off the worms with your bare hands, but they're too numerous.
					Fortunately, they quickly lose interest in you after a few bites.")

	e.add_option("Continue")

	await e.choice
