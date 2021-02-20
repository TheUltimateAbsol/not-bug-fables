extends Control


func _get_party_members(battlers:Array):
	var temp = []
	for battler in battlers:
		if battler.party_member:
			temp.push_back(battler)
	return temp

func initialize(battlers: Array) -> void:
	var party_members = _get_party_members(battlers)
	for i in range($StatMenu.get_child_count()):
		if i < party_members.size():
			$StatMenu.get_child(i).initialize(party_members[i])
		else:
			$StatMenu.get_child(i).hide()
		
func play_intro():
	$AnimationPlayer.play("Intro")
	
func play_exit():
	$AnimationPlayer.play("Exit")
