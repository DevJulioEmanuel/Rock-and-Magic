extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("COLISÃO DETECTADA COM: ", body.name)
	if body == get_parent():
		return
	if body.is_in_group("inimigo"):
		var direcao = (body.global_position - global_position).normalized()
		body.dano(1, direcao)
	elif "meu_id_rede" in body:
		print("Acertei o Jogador Online ID: ", body.meu_id_rede)
		var direcao_empurrao = (body.global_position - global_position).normalized()
		Network.enviar_mensagem({
			"cmd": "HIT",
			"target_id": int(body.meu_id_rede),
			"dano": 1,
			"dir_x": direcao_empurrao.x, 
			"dir_y": direcao_empurrao.y
			})
		
