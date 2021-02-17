extends AnimationPlayer

var block_received:bool = false
var input_received:bool = false
signal input_received
signal attack_ended

func clear_effects():
	for node in get_tree().get_nodes_in_group("effect"):
		node.hide()

func _ready():
	clear_effects()
	connect("animation_finished", self, "end_attack")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("input_received")

func skip_to_next():
	assert(current_animation != null)
	input_received = true
	print("success")
	end_attack()

func start_input_listen():
	input_received = false
	connect("input_received", self, "skip_to_next", [], CONNECT_ONESHOT)
	
func end_input_listen():
	disconnect("input_received", self, "skip_to_next")
	
func input_block():
	block_received = true

func start_block_listen():
	block_received = false
	connect("input_received", self, "input_block", [], CONNECT_ONESHOT)
	
func end_block_listen():
	disconnect("input_received", self, "input_block")

func end_attack(anim_name="idontcare"):
	clear_effects()
	emit_signal("attack_ended")
