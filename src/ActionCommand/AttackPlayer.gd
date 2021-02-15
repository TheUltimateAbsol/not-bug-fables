extends AnimationPlayer

export (int) var segment:int = 0
var attacker:Battler
var target:Battler
var block_received:bool = false
signal input_received
signal attack_ended

func clear_effects():
	for node in get_parent().get_children():
		if node.is_in_group("effect"):
			node.hide()

func _ready():
	clear_effects()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("input_received")

func skip_to_next():
	assert(current_animation != null)
	
	var idx = get_animation(current_animation).find_track("AttackPlayer:segment")
	var target = clamp(segment + 1, 0, get_animation(current_animation).track_get_key_count(idx))
	var target_time = get_animation(current_animation).track_get_key_time(idx, segment + 1)
	
	seek(target_time)
	print("success")

func start_input_listen():
	connect("input_received", self, "skip_to_next", [], CONNECT_ONESHOT)
	
func end_input_listen():
	disconnect("input_received", self, "skip_to_next")
	failure()
	
func input_block():
	block_received = true

func start_block_listen():
	block_received = false
	connect("input_received", self, "input_block", [], CONNECT_ONESHOT)
	
func end_block_listen():
	disconnect("input_received", self, "input_block")

func failure():
	clear_effects()
	#set up animation track to blend
	var anim = get_animation("Failure")
	var position = get_parent().position
	
	var track_position_diff = anim.track_get_key_value(anim.find_track(".:position"), 1) - anim.track_get_key_value(anim.find_track(".:position"), 0)
	var body_rotation = get_parent().get_node("body").rotation_degrees
	var body_position = get_parent().get_node("body").position
	anim.track_set_key_value(anim.find_track("body:position:y"), 0, body_position.y)
	anim.track_set_key_value(anim.find_track("body:rotation_degrees"), 0, body_rotation)	
	
	anim.track_set_key_value(anim.find_track(".:position"), 0, position)
	anim.track_set_key_value(anim.find_track(".:position"), 1, position + track_position_diff)
	anim.track_set_key_value(anim.find_track(".:position"), 2, position + track_position_diff)
	anim.track_set_key_value(anim.find_track(".:position"), 3, position)
	anim.track_set_key_value(anim.find_track(".:position"), 4, position)
	
	play("Failure")
	
func damage():
	assert(target)
	assert(attacker)
	var hit = Hit.new(attacker.stats.strength)
	target.take_damage(hit)

func end_attack():
	emit_signal("attack_ended")
