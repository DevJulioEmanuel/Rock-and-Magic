extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Algo encostou no cogumelo: ", body.name)
	
	if body.has_method("curar"):
		var conseguiu_curar = body.curar(1)
		if conseguiu_curar:
			Network.enviar_mensagem({"cmd": "destruir_item","nome_item": self.name})
			queue_free() 
