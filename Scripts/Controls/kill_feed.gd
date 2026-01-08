extends CanvasLayer

@onready var container = $VBoxContainer

func add_mensagem(texto: String):
	var label = Label.new()
	label.text = texto
	label.modulate = Color.YELLOW 
	
	container.add_child(label)
	
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(label):
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 1.0) 
		await tween.finished
		label.queue_free()
