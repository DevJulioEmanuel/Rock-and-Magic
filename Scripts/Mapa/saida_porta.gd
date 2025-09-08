extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		$"../CharacterBody2D".set_process(false)
		$"../CharacterBody2D".set_physics_process(false)
		var loading = preload("res://Scenes/Controls/tela_carregamento.tscn").instantiate()
		get_tree().root.add_child(loading)
		loading.chamar_carregamento("res://Scenes/Fazenda/principal.tscn")
		global.posicaoPlayer = Vector2(893, 422)		
