#why do I need this in a separate tilemap?
extends TileMap

#All the code in here is very very gay

class_name GameBoard

onready var pawns: YSort = $Pawns
onready var spawning_point = $SpawningPoint

#also sets the camera for the player	
func initialize():
	#normally we get map size but today I accidentally resized it...
	var factor = $Environment.scale.x
	get_player().camera.limit_left = 0
	get_player().camera.limit_top = 0
	get_player().camera.limit_bottom = $Environment.get_extents().end.y*factor
	get_player().camera.limit_right = $Environment.get_extents().end.x*factor
	
	for pawn in pawns.get_children():
		pawn.initialize(self)

#returns the player on the map so that enemies can target
#note: might want to change this later to things like "team position" if we have multiple party members
func get_player()->PawnLeader:
	return pawns.party_members[0]
