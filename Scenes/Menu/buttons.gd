extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button"):
		button.pressed.connect(func():
			on_button_pressed(button)
			)

func on_button_pressed(button: Button) -> void:
	match button.name:
		"Jogar":
			get_tree().change_scene_to_file("res://Scenes/Fazenda/principal.tscn")
		"Controles":
			get_tree().change_scene_to_file("res://Scenes/Menu/controles.tscn")
		"Sair":
			get_tree().quit()
		"Julio Emanuel":
			OS.shell_open("https://www.instagram.com/julioemanuelps/")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_adelta: float) -> void:
	pass
