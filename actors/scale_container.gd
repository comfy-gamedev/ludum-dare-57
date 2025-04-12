@tool
class_name ScaleContainer
extends Container


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		if get_child_count() == 0:
			return
		var c = get_child(0) as Control
		fit_child_in_rect(c, Rect2(Vector2(), size))
		if c.size.x > size.x:
			c.scale.x = size.x / c.size.x

func _get_minimum_size() -> Vector2:
	if get_child_count() == 0:
		return Vector2.ZERO
	return Vector2(0, get_child(0).get_combined_minimum_size().y)

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() != 1:
		return ["ONLY ONE"]
	return []
