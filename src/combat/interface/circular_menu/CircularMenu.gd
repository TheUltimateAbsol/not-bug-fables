extends Control

signal action_selected(action)

onready var tween := $Tween as Tween
onready var labels := $"Flower Select".get_children()
var current_position:int = 0
var active:bool = true
var actor:Battler

enum Directions { LEFT = -1, RIGHT = 1 }
enum Layout { CENTERED = 0, CLOCKWISE = 1, COUNTER_CLOCKWISE = -1 }

const CircularButton := preload("CircularButton.tscn")
const ActionMenu := preload("res://src/combat/interface/circular_menu/ActionMenu.tscn")
const Whoosh := preload("res://src/ActionCommand/194081__potentjello__woosh-noise-1.wav")

export (Layout) var layout: int = Layout.CENTERED
export (float, 0.01, 0.1) var animation_offset: float = 0.08
export (float, 0.1, 0.5) var animation_duration: float = 0.2

func _ready():
	#dirty hack so that it doesn't show up visible for a split second
	modulate = Color.transparent
	#Let's also make sure that the module labels also show up right
	for label in labels:
		label.modulate = Color.transparent
	$"Flower Select/AttackLabel".modulate = Color.white
	
	active = true


func initialize(actor: Battler) -> void:
	self.actor = actor
	
func open() -> void:
	# Plays the open animation on every circular button, with a short time offset
	# Gives focus to the first button
	show()
	AnimFunc.adjust_all_keys_backwards($MenuAnimator.get_animation("Intro"), ".:rect_position:y", rect_position.y)
	$MenuAnimator.play("Intro")
	yield($MenuAnimator, "animation_finished")
	current_position = 0
	
#turn from one label to the next
func transition(old, new):
	tween.interpolate_property(
		labels[old],
		"modulate",
		Color('#ffffffff'),
		Color('#00ffffff'),
		animation_duration,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.interpolate_property(
		labels[new],
		"modulate",
		Color('#00ffffff'),
		Color('#ffffffff'),
		animation_duration,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	var old_angle = $"Flower Select".rotation
	if (old == labels.size()-1 && new == 0):
		print("over")
		old_angle = old*PI/2 - 2*PI
	if (new == labels.size()-1 && old == 0):
		print("under")
		old_angle = old*PI/2 + 2*PI
		
	tween.interpolate_property(
		$"Flower Select",
		"rotation",
		old_angle,
		new*PI/2,
		animation_duration,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	print(old, new)
	current_position = new
	tween.start()
	$AudioStreamPlayer.stream = Whoosh
	$AudioStreamPlayer.play()


func close() -> void:
	AnimFunc.adjust_all_keys($MenuAnimator.get_animation("Exit"), ".:rect_position:y", rect_position.y)
	$MenuAnimator.play("Exit")
	yield($MenuAnimator, "animation_finished")
	queue_free()


func cancel_animation() -> void:
	#probably should add some code to make sure that previous text becomes invisible
	tween.stop_all()
	
#	for button_index in buttons.get_child_count():
#		var button = buttons.get_child(button_index)
#		button.rect_scale = button.unfocused_scale
#		button.rect_position = button.target_position
#	var first_button = buttons.get_child(0)
#	first_button.grab_focus()

func open_menu():
	var new_menu = ActionMenu.instance()
	$ActionMenu.add_child(new_menu)
	new_menu.initialize(actor)
	new_menu.connect("action_selected", self, "_on_ActionMenu_Selection")
	$ConfirmSound.pitch_scale = 1.5
	$ConfirmSound.play()
	active = false

func _unhandled_input(event: InputEvent) -> void:
	if not active: return
	
	var direction := 0
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_focus_next"):
		direction = Directions.RIGHT
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_focus_prev"):
		direction = Directions.LEFT
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_focus_prev"):
		direction = Directions.LEFT
	if event.is_action_pressed("ui_accept"):
		accept_event()
		open_menu()
		return

	if not direction in [Directions.LEFT, Directions.RIGHT]:
		return

	accept_event()
	
	if tween.is_active():
		cancel_animation()
	var next_index = wrapi(current_position + direction, 0, labels.size())
	transition(current_position, next_index)
#
#
func _on_ActionMenu_Selection(action):
	if (action == null):
		active = true
		return
#	yield(close(), "completed")
	$ConfirmSound.pitch_scale = 3
	$ConfirmSound.play()
	close()
	emit_signal("action_selected", action)
#
#
#func _update() -> void:
#	if not is_inside_tree():
#		return
#	for button in buttons.get_children():
#		button.rect_position = _calculate_position(button, buttons.get_child_count())
#
#
#func _calculate_position(button, buttons_count: int) -> Vector2:
#	# Returns the button's position relative to the menu
#	# The calculation is different if the menu is centered over the character,
#	# built clockwise, or counter-clockwise
#	var spacing_angle = spacing * PI
#	var start_offset_angle = offset * PI
#	var button_position: Vector2
#	if layout == Layout.CENTERED:
#		var centering_offset = spacing_angle / 2.0 * (buttons_count - 1)
#		var angle = spacing_angle * button.get_index() - centering_offset + start_offset_angle
#		button_position = Vector2(0, -radius).rotated(angle)
#	else:
#		var angle = spacing_angle * button.get_index() * layout + start_offset_angle
#		button_position = Vector2(0, -radius).rotated(angle)
#	return button_position
#
#
#func set_radius(new_value: float) -> void:
#	radius = new_value
#	_update()
#
#
#func set_spacing(new_value: float) -> void:
#	spacing = new_value
#	_update()
#
#
#func set_offset(new_value: float) -> void:
#	offset = new_value
#	_update()
