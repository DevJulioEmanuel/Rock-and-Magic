extends Area2D

var esta_dentro: bool = false

func _ready() -> void:
	$porta_animation.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and esta_dentro==true:
		get_tree().change_scene_to_file("res://Scenes/Fazenda/Interior_House/casa1.tscn")
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		$porta_animation.visible = true
		esta_dentro = true
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		$porta_animation.visible = false
		esta_dentro = false
