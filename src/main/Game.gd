# Responsible for transitions between the main game screens:
# combat, game over, and the map
extends Node
class_name Game #maybe we should save this for something else?

signal combat_started

enum BATTLE_OPENING_TYPES {STANDARD, PLAYER_HIT, ENEMY_HIT}
const combat_arena_scene = preload("res://src/combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party
onready var music_player = $MusicPlayer
onready var game_over_interface := $GameOverInterface
onready var gui := $GUI

var transitioning = false
var combat_arena: CombatArena
var engaged_enemy:EnemyPawn = null


func _ready():
	QuestSystem.initialize(self, party)
	local_map.spawn_party(party)
	local_map.visible = true
	local_map.connect("enemies_encountered", self, "enter_battle")


func enter_battle(formation: Formation, start_type, enemy:EnemyPawn):
	print(start_type)
	# Plays the combat transition animation and initializes the combat scene
	# not sure what this line here is for. Looks like someone's crappy patch!
	if transitioning:
		return

	engaged_enemy = enemy

	gui.hide()
	music_player.play_battle_theme()

	transitioning = true
	yield(transition.fade_to_color(), "completed")

	remove_child(local_map)
	combat_arena = combat_arena_scene.instance()
	add_child(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.connect("game_over", self, "_on_CombatArena_game_over")
	combat_arena.connect(
		"battle_completed", self, "_on_CombatArena_battle_completed", [combat_arena]
	)
	combat_arena.initialize(formation, party.get_active_members())

	yield(transition.fade_from_color(), "completed")
	transitioning = false

	combat_arena.battle_start(start_type)
	emit_signal("combat_started")


func _on_CombatArena_battle_completed(arena):
	# At the end of an encounter, fade the screen, remove the combat arena
	# and add the local map back
	gui.show()

	transitioning = true
	yield(transition.fade_to_color(), "completed")
	combat_arena.queue_free()
	
	#TODO: add some sort of defeat animation
	if engaged_enemy:
		engaged_enemy.queue_free()

	add_child(local_map)
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	music_player.stop()


func _on_CombatArena_player_victory():
	music_player.play_victory_fanfare()


func _on_CombatArena_game_over() -> void:
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	game_over_interface.display(GameOverInterface.Reason.PARTY_DEFEATED)
	yield(transition.fade_from_color(), "completed")
	transitioning = false


func _on_GameOverInterface_restart_requested():
	game_over_interface.hide()
	var formation = combat_arena.initial_formation
	combat_arena.queue_free()
	enter_battle(formation, 0, engaged_enemy)
