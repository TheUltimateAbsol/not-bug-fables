extends HBoxContainer

const ActionButton := preload("res://src/combat/interface/circular_menu/ActionButton.tscn")
onready var action_list = $MarginContainer/PanelContainer/MarginContainer/ScrollContainer/Actions
onready var scroll_box:ScrollContainer = $MarginContainer/PanelContainer/MarginContainer/ScrollContainer
onready var selection_arrow = $Panel/ArrowContainer
onready var up_arrow = $MarginContainer/PanelContainer/OverflowArrows/Control/Up
onready var down_arrow = $MarginContainer/PanelContainer/OverflowArrows/Control2/Down

enum Directions { DOWN = -1, UP = 1 }

signal action_selected(action)

var update_selection:bool = false
var target_button
var disable_input = false
var fresh = true

func update_selection_arrow():
	selection_arrow.set_global_position(Vector2(selection_arrow.rect_global_position.x, target_button.rect_global_position.y))
	selection_arrow.get_node("AnimationPlayer").play("Animate")
	update_selection = false
	if fresh:
		fresh = false
	else:
		$ScrollSound.play()

#update scrollbar
#update arrow positions
func _process(delta):
	#scrollbar update
	up_arrow.show()
	down_arrow.show()
	if scroll_box.scroll_vertical == 0:
		up_arrow.hide()
	if scroll_box.scroll_vertical >= scroll_box.get_v_scrollbar().max_value - scroll_box.rect_size.y:
		down_arrow.hide()
	#arrow position update
	if update_selection:
		update_selection_arrow()

func initialize(actor: Battler) -> void:
	var actions = actor.actions.get_actions()
	for action in actions:
		var button = ActionButton.instance()
		action_list.add_child(button)
		button.initialize(action)
		button.connect("pressed", self, "_on_ActionButton_pressed", [action])
		button.connect("focus_entered", self, "_on_ActionButton_focus", [button])
	action_list.get_child(0).grab_focus()
	
func close() -> void:
	call_deferred("queue_free")
	
func _on_ActionButton_pressed(action):
	disable_input = true
	close()
	#yield(close(), "completed")
	emit_signal("action_selected", action)
	
func _on_ActionButton_focus(button:Button):
	#queue an update next frame as to not interfere with the box adjustment
	update_selection = true
	target_button = button

func _unhandled_input(event: InputEvent) -> void:
	if disable_input: return
	#If this isn't completely gone before the enemy selection, it will cause an error
	var in_focus: Button = get_focus_owner()
	
	var direction := 0
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_focus_next"):
		direction = Directions.DOWN
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_focus_prev"):
		direction = Directions.UP
	if event.is_action_pressed("ui_cancel"):
		close()
		emit_signal("action_selected", null)
		return

	if not direction in [Directions.DOWN, Directions.UP]:
		return
			
	var next_button_index = (
		(in_focus.get_index() + direction + action_list.get_child_count())
		% action_list.get_child_count()
	)
	action_list.get_child(next_button_index).grab_focus()
