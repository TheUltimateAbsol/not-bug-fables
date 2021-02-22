# Initializes the map's pawns and emits signals so the
# Game node can start encounters
# Processes in pause mode
extends Node
class_name LocalMap

signal enemies_encountered(formation, type, enemy_pawn)
signal dialogue_finished

onready var dialogue_box = $MapInterface/DialogueBox
onready var grid = $GameBoard


func _ready() -> void:
	assert(dialogue_box)
	#heh, I wonder if this is going to activate actions that shouldn't be active?
	for action in get_tree().get_nodes_in_group("map_action"):
		(action as MapAction).initialize(self)
	for enemy in get_tree().get_nodes_in_group("map_enemy"):
		(enemy as EnemyPawn).initialize_action(self)

func spawn_party(party) -> void:
	grid.pawns.spawn_party(grid, party)
	#we initialize after the party spawns so that pawns can use party information
	grid.initialize()

func start_encounter(formation, type, enemy_pawn:EnemyPawn=null) -> void:
	emit_signal("enemies_encountered", formation.instance(), type, enemy_pawn)


func play_dialogue(data):
	dialogue_box.start(data)
	yield(dialogue_box, "dialogue_ended")
