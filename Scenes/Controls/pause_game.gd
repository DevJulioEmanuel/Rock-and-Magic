extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_sair_pressed():
	print("Botão Sair Apertado no Menu de Pause!")
	if has_node("/root/Network"):
		Network.desconectar_do_servidor()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")
	queue_free()
	
func _on_voltar_pressed() -> void:
	$Pause.visible = false
	get_tree().paused = false
