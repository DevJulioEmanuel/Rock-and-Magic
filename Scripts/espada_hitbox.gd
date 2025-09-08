extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print(body.is_in_group)
	if body.is_in_group("inimigo"):
		var direcao = (body.global_position - global_position).normalized()
		body.dano(1, direcao)
	
		
