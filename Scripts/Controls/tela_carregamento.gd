extends Control

func chamar_carregamento(prox_cena: String):
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(prox_cena)
	queue_free()
