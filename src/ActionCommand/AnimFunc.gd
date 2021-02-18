extends Node

func get_key_value(anim:Animation, node_path:NodePath, key:int):
	var track_idx = anim.find_track(node_path)
	var track_get_type = anim.track_get_type(track_idx)
	match track_get_type:
		Animation.TYPE_VALUE: return anim.track_get_key_value(track_idx, key)
		Animation.TYPE_BEZIER:  return anim.bezier_track_get_key_value(track_idx, key)

func get_key_value_from_end(anim:Animation, node_path:NodePath, distance_from_end:int):
	var track_idx = anim.find_track(node_path)
	var new_key = anim.track_get_key_count(track_idx) - 1 - distance_from_end
	return get_key_value(anim, node_path, new_key)

func set_key_value(anim:Animation, node_path:NodePath, key:int, value):
	var track_idx = anim.find_track(node_path)
	var track_get_type = anim.track_get_type(track_idx)
	match track_get_type:
		Animation.TYPE_VALUE: anim.track_set_key_value(track_idx, key, value)
		Animation.TYPE_BEZIER:  anim.bezier_track_set_key_value(track_idx, key, value)

func set_key_value_from_end(anim:Animation, node_path:NodePath, distance_from_end:int, value):
	var track_idx = anim.find_track(node_path)
	var new_key = anim.track_get_key_count(track_idx) - 1 - distance_from_end
	set_key_value(anim, node_path, new_key, value)

func set_last_key_value(anim:Animation, node_path:NodePath, value):
	set_key_value_from_end(anim, node_path, 0, value)

func set_first_key_value(anim:Animation, node_path:NodePath, value):
	set_key_value(anim, node_path, 0, value)

func chain_anim_track(before:Animation, after:Animation, node_path:NodePath):
	set_first_key_value(after, node_path, get_key_value_from_end(before, node_path, 0))

func chain_anim_track_backwards(after:Animation, before:Animation, node_path:NodePath):
	set_last_key_value(before, node_path, get_key_value(after, node_path, 0))

func adjust_all_keys(anim:Animation, node_path:NodePath, base_value):
	var num_keys = anim.track_get_key_count(anim.find_track(node_path))
	var old_values = []
	var new_values = []
	for i in range(num_keys):
		old_values.push_back(get_key_value(anim, node_path, i))
	new_values.push_back(base_value)
	for i in range(1, num_keys):
		new_values.push_back(old_values[i] - old_values[0] + base_value)
	for i in range(num_keys):
		set_key_value(anim, node_path, i, new_values[i])
		
func adjust_all_keys_backwards(anim:Animation, node_path:NodePath, base_value):
	var num_keys = anim.track_get_key_count(anim.find_track(node_path))
	var old_values = []; old_values.resize(num_keys)
	var new_values = []; new_values.resize(num_keys)
	for i in range(num_keys):
		old_values[i] = get_key_value(anim, node_path, i)
	new_values[num_keys-1] = base_value
	for i in range(num_keys-2, -1, -1):
		new_values[i] = old_values[i] - old_values[num_keys-1] + base_value
	for i in range(num_keys):
		set_key_value(anim, node_path, i, new_values[i])
		
func curve_adjust_all(curve:Curve2D, base_value:Vector2):
	var num_points = curve.get_point_count()
	var old_values = []
	var new_values = []
	for i in range(num_points):
		old_values.push_back(curve.get_point_position(i))
	new_values.push_back(base_value)
	for i in range(1, num_points):
		new_values.push_back(old_values[i] - old_values[0] + base_value)
	for i in range(num_points):
		curve.set_point_position(i, new_values[i])
