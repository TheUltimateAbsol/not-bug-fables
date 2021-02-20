extends HBoxContainer
class_name StatBarNumeric

enum {HEALTH, AP}
var max_value: int = 0 setget set_max_value
var value: int = 0 setget set_value


func set_max_value(new_value) -> void:
	max_value = new_value
	$Max.text = str(new_value)

func set_value(new_value) -> void:
	value = new_value
	$Value.text = str(new_value)

func initialize(battler: Battler, type:int) -> void:
	match type:
		HEALTH: _connect_health_value_signals(battler)
		AP: _connect_mana_value_signals(battler)

func _connect_health_value_signals(battler: Battler) -> void:
	var battler_stats = battler.stats
	battler_stats.connect("health_changed", self, "_on_value_changed")
	battler_stats.connect("health_depleted", self, "_on_value_depleted")
	self.max_value = battler_stats.max_health
	self.value = battler_stats.health
	
func _connect_mana_value_signals(battler: Battler) -> void:
	var battler_stats = battler.stats
	battler_stats.connect("mana_changed", self, "_on_value_changed")
	battler_stats.connect("mana_depleted", self, "_on_value_depleted")
	self.max_value = battler_stats.max_mana
	self.value = battler_stats.mana

func _on_value_changed(new_value, old_value) -> void:
	self.value = new_value

#This happens when the bar uns out... we don't have anything special right now
func _on_value_depleted() -> void:
	pass
