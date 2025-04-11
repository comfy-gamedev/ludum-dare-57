extends RefCounted

var selected_mutation: Mutation = null
var gained_item: String = "nothing"

func run(e: EventScene) -> void:
	if not Globals.player_stats.mutations.is_empty():
		selected_mutation = Globals.player_stats.mutations.pick_random()

	e.set_image(load("res://assets/textures/event_icons/item_in_side_tunnel.png"))
	e.set_description("
		You see a dark tunnel leading off to the side. There seems to be something shiny
		lying in the water that direction. Could be a useful item.")
	e.add_option("
		Wade into the water and grab it.
		What's the worst that could happen?
		(Gain an item. Move forward)")
	e.add_option("
		Play it safe and walk along the edge of the tunnel where it's dry.
		(Gain an item. Lose 1 mutation)")
	e.add_option("Ignore.")

	var choice = await e.choice

	e.clear()

	match choice:
		0:
			gained_item = Globals.player_stats.add_equipment()
			# Globals.player_nav_event = "forward"
			e.set_description("
				You've found a {item} here in the water! Uh-oh, this water is deeper and faster
				than you thought. Your foot slips and you get carried deeper into the sewer."
			.format({ item = gained_item }))
		1:
			gained_item = Globals.player_stats.add_equipment()
			if not Globals.player_stats.mutations.is_empty():
				var mut: Mutation = Globals.player_stats.mutations.pick_random()
				Globals.player_stats.mutations.erase(mut)
				e.set_description("
					Oops, you step on a syringe that's lying on the ground. You easily fish the {item}
					out of the water, but whatever was in that syringe neutralized your {mutation} mutation."
				.format({ item = gained_item, mutation = mut.get_name() }))
			else:
				e.set_description("
					Oops, you step on a syringe that's lying on the ground. You easily fish the {item}
					out of the water. Fortunately, you have no mutations to lose."
				.format({ item = gained_item }))
		2:
			return

	e.add_option("Continue")

	await e.choice
