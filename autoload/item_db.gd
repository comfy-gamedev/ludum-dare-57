extends Node

const ITEM_DIR = "res://assets/items"

const DEFAULT_RATES = {
	Enums.ITEM_RARITY.COMMON: 1.0,
	Enums.ITEM_RARITY.UNCOMMON: 0.3,
	Enums.ITEM_RARITY.RARE: 0.05,
}

var items = {
	Enums.ITEM_RARITY.COMMON: [],
	Enums.ITEM_RARITY.UNCOMMON: [],
	Enums.ITEM_RARITY.RARE: [],
	Enums.ITEM_RARITY.ULTRA_RARE: [],
	Enums.ITEM_RARITY.UNAVAILABLE: [],
}

func _ready() -> void:
	for f in DirAccess.get_files_at(ITEM_DIR):
		var path = ITEM_DIR.path_join(f).trim_suffix(".remap")
		var item: StuffDie = load(path)
		items[item.item_rarity].append(path)


func pick_n(n: int, rates: Dictionary = DEFAULT_RATES) -> Array[StuffDie]:
	var results: Array[StuffDie]
	
	var ordered_rates = []
	for r in rates:
		ordered_rates.append({ rarity = r, rate = rates[r] })
	ordered_rates.sort_custom(func (a, b): return a.rate < b.rate)
	
	var available_items = items.duplicate(true)
	
	for i in n:
		var item: StuffDie
		var roll = randf()
		for rate in ordered_rates:
			var list = available_items[rate.rarity]
			if roll <= rate.rate and not list.is_empty():
				var j = randi_range(0, list.size() - 1)
				item = load(list[j])
				list.remove_at(j)
				break
		assert(item)
		results.append(item)
	
	return results

