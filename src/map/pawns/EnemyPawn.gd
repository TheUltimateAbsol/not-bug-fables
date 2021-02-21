tool
# Set to Stop during pause
extends KinematicBody2D
#
export var DRAW_COLOR := Color("#e231b6")
class_name EnemyPawn
export var formation: PackedScene
export var patrol_path_nodepath : NodePath
onready var patrol_path : Path2D

enum MOVE_TYPE {PATROL, WANDER, IDLE}
export(MOVE_TYPE) var move_type

var game_board
var local_map
#onready var anim: PawnAnim = pivot.get_node("PawnAnim")

#"BORROWED" CODE ########################################3
export var attack_speed := 1.0
export var speed := 80.0
export(float) var agro_dist := 100.0
onready var agro_area_collision : CollisionShape2D = $AgroArea/CollisionShape2D
onready var raycasts := [$RayCastDown, $RayCastLeft, $RayCastUp, $RayCastRight]
export var attack_range := Vector2(2.0, 2.0)
onready var attack_timer : Timer = $AttackTimer

var patrol_direction := 1
var agro := false setget set_agro
var target_position := position

func draw_circle_donut_poly(center, inner_radius, outer_radius, angle_from, angle_to, color):  
	var nb_points = 32  
	var points_arc = PoolVector2Array()  
	var points_arc2 = PoolVector2Array()  
	var colors = PoolColorArray([color])  

	for i in range(nb_points+1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * outer_radius)  
	for i in range(nb_points,-1,-1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * inner_radius)  
	draw_polygon(points_arc, colors)  

func _draw() -> void:
	if not Engine.editor_hint:
		return
	draw_circle_donut_poly(Vector2(), agro_dist, agro_dist + 5, 0, 360, DRAW_COLOR)

func set_agro(value):
	agro = value
	
	if agro:
		agro_area_collision.shape.set_radius(agro_dist * 2)
	else:
		agro_area_collision.shape.set_radius(agro_dist)

func _ready():
	attack_timer.set_wait_time(1.0 / attack_speed)
	attack_timer.start()
	
	target_position = position
		
	agro_area_collision.shape.set_radius(agro_dist)
	
	for raycast in raycasts:
		#raycast.add_exception(PlayerStats.player)
		target_position += Vector2.RIGHT.rotated(randf() * 2 * PI)
	
	if(move_type == MOVE_TYPE.PATROL):
		patrol_path = get_node(patrol_path_nodepath)

func _process(_delta):
	if(agro_area_collision.disabled):
		agro = true
	
	if(agro):
		#target_position = PlayerStats.player.position
		if((target_position - position).length() < attack_range.x * 32):
			if(attack_timer.time_left == 0.0):
				attack_timer.start()
				attack_timer.connect("timeout", self, "attack", [target_position - position], CONNECT_ONESHOT)
	else:
		match(move_type):
			MOVE_TYPE.PATROL:
				patrol(_delta)
			MOVE_TYPE.WANDER:
				wander(_delta)
			MOVE_TYPE.IDLE:
				target_position = position
	
	get_node("../Sprite").position = target_position
	
	var velocity = target_position - position
	velocity = velocity.normalized() * min(velocity.length(), speed)
	move_and_slide(velocity)

func take_damage(damage : float, direction : Vector2, force := 5.0):
	.take_damage(damage, direction, force)
	set_agro(true)
	agro_area_collision.set_deferred("disabled", true)

func attack(target_local : Vector2):
	var attack_transform := Transform2D(Vector2.RIGHT * 16, Vector2.UP * 16.0, Vector2.RIGHT * 16.0)
	attack_transform = attack_transform.scaled(attack_range)
	attack_transform = attack_transform.rotated((target_local).angle())
	
	#create_attack_area(attack_damage, attack_transform, ["player"], attack_knockback, attack_animation)
	
	get_tree().create_timer(attack_timer.wait_time * 0.3).connect("timeout", self, "set", ["speed", speed])
	speed = 0

func patrol(_delta : float):
	var relative_position := patrol_path.to_local(position)
	var target_offset := patrol_path.curve.get_closest_offset(relative_position)
	target_offset += speed * patrol_direction
	target_position = patrol_path.curve.interpolate_baked(target_offset)
	target_position = patrol_path.to_global(target_position)
	
	if(target_offset >= patrol_path.curve.get_baked_length() - 10 || target_offset <= 10):
		if(target_position.distance_to(position) < 30):
			patrol_direction *= -1

func wander(_delta : float):
	var direction = target_position - position
	direction = direction.rotated(rand_range(-5.0, 5.0) * _delta)
	
	var obstacles := []
	for i in range(get_slide_count()):
		obstacles.append((get_slide_collision(i).position - position).normalized())
	for raycast in raycasts:
		if(raycast.is_colliding()):
			obstacles.append(raycast.cast_to.normalized())
	
	if(obstacles != []):
		direction = Vector2.ZERO
		for vec in obstacles:
			direction -= vec
		direction = direction.rotated(rand_range(-0.5, 0.5))
	
	target_position = position + direction.normalized() * speed

func _on_AgroArea_body_entered(body):
	pass
#	if body == PlayerStats.player:
#		set_agro(true)

func _on_AgroArea_body_exited(body):
	pass
#	if(body == PlayerStats.player):
#		set_agro(false)

##################################################################################



#What's the point of this function????
func initialize(board):
	game_board = board
	print("initialized gameboard")
	
func initialize_action(map):
	local_map = map
	print("initialized localmap")
	$Pivot/PawnAnim.connect("encountered", self, "encounter_start")

func encounter_start(type):
	print("Encountered ", type)
	get_tree().paused = false
	local_map.start_encounter(formation)
	
	#need to add some way of deleting after the battle is over
	queue_free()

