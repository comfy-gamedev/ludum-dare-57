extends RefCounted

var selected_item: StuffDie = null
var gained_mutation: String = "nothing"

func run(e: EventScene) -> void:
	if not Globals.player_stats.equipment.is_empty():
		selected_item = Globals.player_stats.equipment.pick_random()

	e.set_image(load("res://assets/textures/event_icons/slimed.png"))
	e.set_description("
		Ew, gross! A bunch of mysterious slime just fell on you.")
	e.add_option("
		Just leave it. Everything here is a little slimy anyway.
		You'll probably be fine.
		(Lose 1 item. Gain a mutation)")
	e.add_option("
		Jump in the water and try to clean the slime off.
		(Move forward. Gain a mutation)")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			gained_mutation = Globals.player_stats.add_mutation()
			if selected_item != null:
				Globals.player_stats.equipment.erase(selected_item)
				e.set_description("
					The slime seems fine. In fact, you gradually realize that it has given you
					a {mutation} mutation. It did ruin your {item} however."
				.format({ mutation = gained_mutation, item = selected_item.name }))
			else:
				e.set_description("
					The slime seems fine. In fact, you gradually realize that it has given you
					a {mutation} mutation. Fortunately, you had no items for it to ruin."
				.format({ mutation = gained_mutation }))
		1:
			gained_mutation = Globals.player_stats.add_mutation()
			# Globals.player_nav_event = "forward"
			e.set_description("
				The slime washes off easily, but it has already reacted with your skin,
				causing a {mutation} mutation. When you get out of the water, you realize
				the current has carried you deeper into the sewer."
			.format({ mutation = gained_mutation }))

	e.add_option("Continue")

	await e.choice
