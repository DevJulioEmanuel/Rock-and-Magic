extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button"):
		button.pressed.connect(func():
			on_button_pressed(button)
			)

func on_button_pressed(button: Button) -> void:
	match button.name:
		"Voltar":
			get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
