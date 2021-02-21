#why do I need this in a separate tilemap?
extends TileMap

#All the code in here is very very gay

class_name GameBoard

onready var pawns: YSort = $Pawns
onready var spawning_point = $SpawningPoint

#Should pawns really be spawned separately?
#What happens if I want non-pawn game objects (i.e. paths, trees)
func _ready():
	for pawn in pawns.get_children():
		pawn.initialize(self)
