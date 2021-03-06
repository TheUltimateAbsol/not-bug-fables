extends AudioStreamPlayer

const map_theme = preload("res://assets/audio/bgm/game_maoudamashii_6_dangeon21.ogg")
const battle_theme = preload("res://assets/audio/bgm/game_maoudamashii_1_battle37.ogg")
const victory_fanfare = preload("res://assets/audio/bgm/victory_fanfare.ogg")

func play_map_theme():
	stream = map_theme
	play()

func play_battle_theme():
	stream = battle_theme
	play()


func play_victory_fanfare():
	stream = victory_fanfare
	play()
