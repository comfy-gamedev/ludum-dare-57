extends Node2D

enum EVENTS {
	CLEAR_WATER,
	STRANGE_BREW,
	TUNNEL_REST,
	LOG_PEEK,
	SHINY_OBJECT,
	RAT_GIRL,
	WORMS,
	SLIME,
	BIOHAZARD,
	LADDER,
	SPINNING_BLADES,
	CLOGGED_PIPE
}

var event := -1 #EVENTS.CLEAR_WATER
var choice := -1

@onready var option1 := $VBoxContainer/Option1
@onready var option2 := $VBoxContainer/Option2
@onready var skip := $VBoxContainer/Skip
@onready var event_text := $VBoxContainer/EventBox/EventText
@onready var event_box := $VBoxContainer/EventBox
@onready var event_pic := $VBoxContainer/EventBox/EventPic

var selected_item : StuffDie
var gained_item := "nothing"
var selected_mutation : Mutation
var gained_mutation := "nothing"

func _ready() -> void:
	event = randi_range(0, 11)
	
	if event in [EVENTS.RAT_GIRL, EVENTS.WORMS, EVENTS.SLIME, EVENTS.SPINNING_BLADES ]:
		skip.visible = false
	
	selected_item = Globals.player_stats.equipment.pick_random() if Globals.player_stats.equipment.size() > 0 else null
	selected_mutation = Globals.player_stats.mutations.pick_random() if Globals.player_stats.mutations.size() > 0 else null
	
	match event:
		EVENTS.CLEAR_WATER:
			event_text.text = "The sewer makes a turn here, and there's a section of water that's remarkably clean and clear. Now would be a great time to rinse off and dress some of your wounds. (Small Heal)"
<<<<<<< Updated upstream
<<<<<<< Updated upstream
			option1.text = "Take off your equipment before jumping in for a swim (lose 1 item)"
			option2.text = "Jump in fully clothed. Don't want to risk losing any of your precious stuff! (lose 1 mutation)"
			event_pic.texture = preload("res://assets/textures/event_icons/clear_water_pool.png")
		EVENTS.STRANGE_BREW:
			event_text.text = "You see thermos sitting here. It seems to be filled with a thick, warm liquid. Could be delicious? (Small Heal)"
			option1.text = "Take the thermos with you and drink as you keep walking (lose 1 item)"
=======
			option1.text = "Take off your equipment before jumping in. (lose 1 item/relic)"
			option2.text = "Just jump in. Don't want to lose your precious stuff! (lose 1 mutation)"
			event_pic.texture = preload("res://assets/textures/event_icons/clear_water_pool.png")
		EVENTS.STRANGE_BREW:
=======
			option1.text = "Take off your equipment before jumping in. (lose 1 item/relic)"
			option2.text = "Just jump in. Don't want to lose your precious stuff! (lose 1 mutation)"
			event_pic.texture = preload("res://assets/textures/event_icons/clear_water_pool.png")
		EVENTS.STRANGE_BREW:
>>>>>>> Stashed changes
			event_text.text = "You see a thermos sitting here. It seems to be filled with a thick, warm liquid. Could be delicious? (Small Heal)"
			option1.text = "Take the thermos with you and drink as you keep walking (lose 1 item/relic)"
>>>>>>> Stashed changes
			option2.text = "Stop and drink the whole thing right here. (travel forward)"
			event_pic.texture = preload("res://assets/textures/event_icons/Thermos.png")
		EVENTS.TUNNEL_REST:
			event_text.text = "You see a side tunnel, and it feels strangely warm. This could be a good place to stop and rest."
			option1.text = "Play it safe and stay awake while you rest (lose 1 mutation)"
			option2.text = "Lay down and take a quick nap (Jump ahead)"
			event_pic.texture = preload("res://assets/textures/event_icons/Pipe side tunnel.png")
		EVENTS.LOG_PEEK:
			event_text.text = "There's a big, slimy-looking log over here. It looks like there might be something under it."
			option1.text = "Roll the log forward to see what's under it (Lose hp)"
			option2.text = "Roll the log backward to see what's under it (Lose 1 mutation)"
			event_pic.texture = preload("res://assets/textures/event_icons/Slimy Log.png")
		EVENTS.SHINY_OBJECT:
			event_text.text = "You see a dark tunnel leading off to the side. There seems to be something shiny lying in the water that direction. Could be a useful item."
			option1.text = "Wade into the water and grab it. What's the worst that could happen?"
			option2.text = "Play it safe and walk along the edge of the tunnel where it's dry."
			event_pic.texture = preload("res://assets/textures/event_icons/item_in_side_tunnel.png")
		EVENTS.RAT_GIRL:
			event_text.text = "You are walking along, when all of a sudden a Ratgirl jumps out of the shadows at you!"
			option1.text = "Stand your ground. Why should you be scared of a skinny little Ratgirl? (lose health)"
			option2.text = "Run away. There's no point fighting when you could easily outrun her."
			event_pic.texture = preload("res://assets/textures/event_icons/rat_ambush.png")
		EVENTS.WORMS:
<<<<<<< Updated upstream
<<<<<<< Updated upstream
			event_text.text = "The water here is almost knee-deep, which is why you didn't notice a swarm of purplish worm creatures until just now, as they start biting you."
			option1.text = "Back away and cut open the wound and try to remove the poison (lose HP)"
			option2.text = "Fend off the creatures with your {} (lose 1 item)".format([selected_item.name if selected_item != null else "nothing"], "{}")
=======
=======
>>>>>>> Stashed changes
			event_text.text = "The water here is almost knee-deep, which is why you didn't notice that swarm of purplish worm creatures until just now, as they start biting you."
			option1.text = "Back away and cut open the wound to try to remove the poison (lose HP)"
			option2.text = "Fend off the creatures with your {ItemName} (lose 1 item)"
>>>>>>> Stashed changes
			event_pic.texture = preload("res://assets/textures/event_icons/worms.png")
		EVENTS.SLIME:
			event_text.text = "Ew, gross! a bunch of mysterious slime just fell on you."
			option1.text = "Just leave it. Everything here is a little slimy anyway. You'll probably be fine. (lose 1 item)"
			option2.text = "Jump in the water and try to clean the slime off. (move forward)"
			event_pic.texture = preload("res://assets/textures/event_icons/slimed.png")
		EVENTS.BIOHAZARD:
			event_text.text = "There's a pipe in the wall here, with a grubby \"biohazard\" sign on the wall. The sewage coming from the pipe seems to have a greenish glow."
			option1.text = "Inspect the glowing water more closely (lose hp)"
			option2.text = "Avoid the glowing water (jump forward)"
			event_pic.texture = preload("res://assets/textures/event_icons/biohazard.png")
		EVENTS.LADDER:
			event_text.text = "You see a ladder leading upward, and... Is that daylight? You've been down in these depths for so long, you can't be sure anymore."
			option1.text = "Open the manhole and peek out, to make sure the coast is clear (lose hp)"
			option2.text = "Open the manhole with your {}, to avoid an ambush from watever might be up there (lose 1 item)".format([selected_item.name if selected_item != null else "nothing"], "{}")
			event_pic.texture = preload("res://assets/textures/event_icons/Ladder.png")
		EVENTS.SPINNING_BLADES:
			event_text.text = "The entire sewer tunnel is blocked here by some large spinning blades. Perhaps a fan or turbine of some sort?"
			option1.text = "The blades are spinning slow enough. You could try to jump through, if you time it just right. (lose hp)"
<<<<<<< Updated upstream
<<<<<<< Updated upstream
			option2.text = "Better play it safe and jam the mechanism with your {}. You didn't need that thing anyway, right? (lose 1 item)".format([selected_item.name if selected_item != null else "nothing"], "{}")
=======
			option2.text = "Jam the mechanism with your {ItemName}. You didn't need that thing anyway, right? (lose 1 item)"
>>>>>>> Stashed changes
=======
			option2.text = "Jam the mechanism with your {ItemName}. You didn't need that thing anyway, right? (lose 1 item)"
>>>>>>> Stashed changes
			event_pic.texture = preload("res://assets/textures/event_icons/spinning fan.png")
		EVENTS.CLOGGED_PIPE:
			event_text.text = "The water ahead keeps getting deeper and deeper, until it's no longer passable. The entire sewer pipe must be clogged in this direction."
			option1.text = "Use your {} to try to clear the blockage (lose 1 item)".format([selected_item.name if selected_item != null else "nothing"], "{}")
			option2.text = "Dive in and try to find a way around (lose 1 mutation)"
			event_pic.texture = preload("res://assets/textures/event_icons/clogged.png")
			

func _reveal_consequences() -> void:
	option1.visible = false
	option2.visible = false
	skip.visible = true
	skip.text = "Continue"
	event_box.custom_minimum_size = Vector2(800, 400)
	
	match event:
		EVENTS.CLEAR_WATER:
			if choice == 1:
				event_text.text = "The cool water refreshes you, but when you leave the pool, you find your {} is missing.".format([selected_item.name if selected_item != null else "nothing"], "{}")
			else:
				event_text.text = "You feel cleaner and more refreshed after a dip in the pool. Unfortunately, your {} mutation seems to have also washed away".format([selected_mutation.name if selected_item != null else "nothing"], "{}")
		EVENTS.STRANGE_BREW:
			if choice == 1:
				event_text.text = "As you're walking, a sewer worker catches you stealing their thermos. They demand your {} from you in exchange.".format([selected_item.name if selected_item != null else "nothing"], "{}")
			else:
				event_text.text = "You stop to enjoy the meal, and are caught off guard as a wave crashes through the sewer. You are washed 2 spaces downstream."
		EVENTS.TUNNEL_REST:
			if choice == 1:
				event_text.text = "As you rest, you start to see strange visions... too late you realize the fumes from this tunnel are making you hallucinate. By the time you get up, you notice that your {} mutation is gone!".format([selected_item.name if selected_item != null else "nothing"], "{}")
			else:
				event_text.text = "You fall asleep easily, having wild and vivid dreams. When you wake, you realize you have moved deeper into the sewer somehow"
		EVENTS.LOG_PEEK:
			if choice == 1:
<<<<<<< Updated upstream
<<<<<<< Updated upstream
				event_text.text = "Oops! there was a cetipede uder there. It doesn't seem happy to have a visitor and gives you a painful bite. At least you found a {} ".format([gained_item], "{}")
=======
				event_text.text = "Oops! there was a centipede under there. It doesn't seem happy to have a visitor and gives you a painful bite. At least you found a {ItemName} "
>>>>>>> Stashed changes
=======
				event_text.text = "Oops! there was a centipede under there. It doesn't seem happy to have a visitor and gives you a painful bite. At least you found a {ItemName} "
>>>>>>> Stashed changes
			else:
				event_text.text = "You wisely roll the log backward. An angry centipede jumps out from under the log, away from you. You've discovered an {}! The slime seems to have reacted with your skin however, neutralizing your {} mutation".format([gained_item, selected_mutation.name if selected_mutation != null else "nothing", ], "{}")
		EVENTS.SHINY_OBJECT:
			if choice == 1:
				event_text.text = "You've found a {} here in the water! Uh-oh, this water is deeper and faster than you thought. Your foot slips and you get carried deeper into the sewer.".format([gained_item], "{}")
			else:
				event_text.text = "Oops, you step on a syringe that's lying on the ground. You easily fish the {} out of the water, but whatever was in that syringe neutralized your {} mutation".format([gained_item, selected_mutation.name if selected_mutation != null else "nothing"], "{}")
		EVENTS.RAT_GIRL:
			if choice == 1:
				event_text.text = "You fend her off easily, but she does manage to bite you in the scuffle. Looks like she was carrying a {}. It's yours now.".format([gained_item], "{}")
			else:
				event_text.text = "You start jogging down the sewer when you realize she's faster than she looked. By the time you've lost her, you don't recognize where you are anymore. But you did stumble across a {} just laying on the ground.".format([gained_item], "{}")
		EVENTS.WORMS:
			if choice == 1:
				event_text.text = "Fortunately, the \"poison\" seems to have only given you a new mutation. Unfortunately, you were a little overzealous in trying to remove the poison. that cut looks like it might be infected..."
			else:
				event_text.text = "You try to fend off the worms with your {}, but they manage to wrench it out of your grip. After that, they quickly lose interest in you. Unfortunately, in this murky water, you're never getting that {} back.".format([selected_item.name if selected_item != null else "nothing"], "{}")
		EVENTS.SLIME:
			if choice == 1:
				event_text.text = "The slime seems fine. in fact, you gradually realize that it has given you a {} mutation. It did ruin your {} however.".format([gained_mutation, selected_item.name if selected_item != null else "nothing"], "{}")
			else:
				event_text.text = "The slime washes off easily, but it has already reacted with your skin, causing a {} mutation. When you get out of the water, you realize the current has carried you deeper into the sewer.".format([gained_mutation], "{}")
		EVENTS.BIOHAZARD:
			if choice == 1:
				event_text.text = "You lean down to get a closer look at the glowing sewage. At this distance though, the smell hits you right in the face. As you recoil, you slip and bump your head, falling into the water. It burns, but you can feel yourself starting to mutate."
			else:
				event_text.text = "You walk down the path and realize this may be a shortcut, leading you even deeper into the sewer. After a while you get used to the smell of the glowing water, and realize that the fumes have begun to mutate you!"
		EVENTS.LADDER:
			if choice == 1:
				event_text.text = "The way seems clear, and you climb up into... another sewer. It seems you've been down here too long after all. That definitely wasn't daylight. As your mind wanders, the manhole cover falls on your foot. Ow!"
			else:
				event_text.text = "You carefully lift the manhole cover with your {}, only to find that the way is clear. There was never any danger. The cover slips though, crushing your {}. At least you've discovered a new path... Wait! This area feels eerily familiar.".format([selected_item.name if selected_item != null else "nothing"], "{}")
		EVENTS.SPINNING_BLADES:
			if choice == 1:
				event_text.text = "OOps! You did not time it just right. Well that hurt... At least the tunnel on the other side seems to lead somewhere useful."
			else:
				event_text.text = "You jam your {} into the spinning motor and it grinds to a halt. It also grinds up your {} until it's unrecognizeable. The tunnel on the other side seems to lead somewhere familiar. Have you been here before?".format([selected_item.name if selected_item != null else "nothing"], "{}")
		EVENTS.CLOGGED_PIPE:
			if choice == 1:
				event_text.text = "You stick your {} in there and wiggle it around trying to break loose the blockage, but it's no use. Eventually your {} gets stuck and you give up, doubling back to try to find another way around.".format([selected_item.name if selected_item != null else "nothing"], "{}")
			else:
				event_text.text = "You dive in and eventually find a branch of the sewer that leads back up and off in another direction. The stagnant water sems to have reacted with your {MutationName} mutation, causing it to reverse."


func _on_option_1_pressed() -> void:
	match event:
		EVENTS.CLEAR_WATER:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.STRANGE_BREW:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.TUNNEL_REST:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_stats.mutations.erase(selected_mutation)
		EVENTS.LOG_PEEK:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.SHINY_OBJECT:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_nav_event = "forward"
		EVENTS.RAT_GIRL:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.WORMS:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.SLIME:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.BIOHAZARD:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.LADDER:
			Globals.player_nav_event = "back"
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.SPINNING_BLADES:
			Globals.player_nav_event = "back"
			Globals.player_stats.health = Globals.player_stats.health / 2
		EVENTS.CLOGGED_PIPE:
			Globals.player_nav_event = "back"
			Globals.player_stats.equipment.erase(selected_item)
	
	choice = 1
	_reveal_consequences()


func _on_option_2_pressed() -> void:
	match event:
		EVENTS.CLEAR_WATER:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_stats.mutations.erase(selected_mutation)
		EVENTS.STRANGE_BREW:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_nav_event = "forward"
		EVENTS.TUNNEL_REST:
			Globals.player_stats.health = Globals.player_stats.max_health
			Globals.player_nav_event = "forward"
		EVENTS.LOG_PEEK:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.mutations.erase(selected_mutation)
		EVENTS.SHINY_OBJECT:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_stats.mutations.erase(selected_mutation)
		EVENTS.RAT_GIRL:
			gained_item = Globals.player_stats.add_equipment()
			Globals.player_nav_event = "forward"
		EVENTS.WORMS:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.SLIME:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_nav_event = "forward"
		EVENTS.BIOHAZARD:
			gained_mutation = Globals.player_stats.add_mutation()
			Globals.player_nav_event = "forward"
		EVENTS.LADDER:
			Globals.player_nav_event = "back"
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.SPINNING_BLADES:
			Globals.player_nav_event = "back"
			Globals.player_stats.equipment.erase(selected_item)
		EVENTS.CLOGGED_PIPE:
			Globals.player_nav_event = "back"
			Globals.player_stats.mutations.erase(selected_mutation)
	
	choice = 2
	_reveal_consequences()


func _on_skip_pressed() -> void:
	SceneGirl.pop_scene()
