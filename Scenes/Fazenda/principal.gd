extends Node


func _ready() -> void:
	$Mapa/ground/ysorting/CharacterBody2D.position = global.posicaoPlayer
	MissionManager.start_mission("mission_1")

func _process(_delta: float) -> void:
	pass
	
func _unhandled_input(event):
	if event.is_action_pressed("esc_menu"): 
		if not $Controles/PauseGame/Pause.visible:
			$Controles/PauseGame/Pause.visible = true
			get_tree().paused = true
		else:
			$Controles/PauseGame/Pause.visible = false
			get_tree().paused = false

func _on_voltar_pressed() -> void:
	$Controles/PauseGame/Pause.visible = false
	get_tree().paused = false


func _on_sair_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")
