extends Node

var missions = preload("res://Scripts/Missions/missions.gd").new().missions

signal mission_started(mission_id)
signal mission_completed(mission_id)

func _ready():
	connect("mission_completed", Callable(self, "_on_mission_completed"))

func _on_mission_completed(mission_id):
	print("Missão concluída: %s" % missions[mission_id].name)
	
func start_mission(mission_id: String):
	if missions[mission_id].status == "locked":
		missions[mission_id].status = "active"
		emit_signal("mission_started", mission_id)

func complete_mission(mission_id: String):
	if missions[mission_id].status == "active":
		missions[mission_id].status = "completed"
		emit_signal("mission_completed", mission_id)

		var next_mission = missions[mission_id].next
		if next_mission:
			start_mission(next_mission)


	
