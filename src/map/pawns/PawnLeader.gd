# Player-controlled pawn.
# Set to Stop during pause
extends KinematicBody2D
#
class_name PawnLeader

const RUN_SPEED = 8.0

var _path_current := PoolVector3Array()
var _direction := Vector2()
var game_board
onready var pivot = $Pivot
onready var anim: PawnAnim = pivot.get_node("PawnAnim")
signal moved(last_position, current_position)

func initialize(board):
	game_board = board

func _process(delta: float) -> void:
	if _direction != Vector2():
		anim.walk(_direction)
		move_and_collide(_direction*RUN_SPEED)
	else:
		anim.stand()

#Gets current key state direction
#TODO: Add axises to here as well
func get_key_input_direction() -> Vector2:
	var dir = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	return dir.normalized()

func attack():
	set_process(false)
	yield(anim.attack(), "completed")
	set_process(true)

func _unhandled_input(event: InputEvent) -> void:
	#We don't care about echos because they provide no new data
	if event is InputEventKey and not event.is_echo():
		_direction = get_key_input_direction()
		if event.is_action_pressed("ui_accept"):
			attack()


func change_skin(pawn_anim: PawnAnim):
	# Replaces the pawn's animated character with another
	if anim:
		anim.queue_free()
	anim = pawn_anim
	pivot.add_child(pawn_anim)
