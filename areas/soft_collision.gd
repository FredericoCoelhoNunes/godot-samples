# can be used by a character to check if its overlapping with others
# and get a little push during its movement loop.
# not optimized but it works well for a moderate number of moving characters
# don't forget to set soft collision areas and layer
extends Area2D

func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0
	
func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	if is_colliding():
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)
		push_vector = push_vector.normalized()
	return push_vector