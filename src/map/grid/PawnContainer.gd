# Container for all pawns on the map.
# Sorts pawns by their Y position,
# Spawns and rebuilds the player's party
extends YSort

export var party_scene: PackedScene

const Leader = preload("res://src/map/pawns/PawnLeader.tscn")

var party_members := []
var party

#For now, we're only spawning the leader
func spawn_party(game_board, party: Object) -> void:
	self.party = party
	#first party member is the leader
	#can add more characters in the future
	party_members.append(spawn_pawn(party.get_child(0), game_board, null, true))

#For now, we're only spawning the leader person
func spawn_pawn(
	party_member: PartyMember, game_board: GameBoard, pawn_previous: Object, is_leader: bool = false
) -> Object:
	var new_pawn = Leader.instance()
	new_pawn.name = party_member.name
	new_pawn.position = game_board.spawning_point.position
	add_child(new_pawn)
	new_pawn.change_skin(party_member.get_pawn_anim())
	return new_pawn


func rebuild_party() -> void:
	var Leader_pos = party_members[0].position
	for member in party_members:
		member.queue_free()
	party_members.clear()
	spawn_party(party, Leader_pos)
