extends Node

var other_player_scene = preload("res://Scenes/Personagem/player_online.tscn")

var jogadores_na_tela = {}

func _ready() -> void:
	$Mapa/ground/ysorting/CharacterBody2D.position = global.posicaoPlayer
	MissionManager.start_mission("mission_1")
	
	Network.connect("jogador_moveu", _on_jogador_moveu)
	Network.connect("jogador_saiu", _on_jogador_saiu)
	Network.connect("jogador_atacou", _on_jogador_atacou)
	Network.connect("jogador_curou", _on_jogador_curou)
	Network.connect("item_destruido", _on_item_destruido)
	Network.knockback_aplicado.connect(_on_knockback)
	Network.jogador_morreu.connect(_on_jogador_morreu)

func _process(_delta: float) -> void:
	pass
	
func _unhandled_input(event):
	if event.is_action_pressed("esc_menu"): 
		if not $Controles/PauseGame/Pause.visible:
			$Controles/PauseGame/Pause.visible = true
			get_tree().paused = true
		else:
			$Controles/PauseGame/Pause.visible = false
			get_tree().paused = false

func _on_voltar_pressed() -> void:
	$Controles/PauseGame/Pause.visible = false
	get_tree().paused = false


func _on_sair_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")
	


#PARTE DO MULTIPLAYER
	
func _on_jogador_moveu(id, x, y, anim, flip, nome):
	if jogadores_na_tela.has(id) and not is_instance_valid(jogadores_na_tela[id]):
		jogadores_na_tela.erase(id) 

	if not jogadores_na_tela.has(id):
		var novo_boneco = other_player_scene.instantiate()
		novo_boneco.position = Vector2(x, y) 
		novo_boneco.meu_id_rede = id
		add_child(novo_boneco)
		jogadores_na_tela[id] = novo_boneco
	
	jogadores_na_tela[id].mover_para(x, y, anim, flip)
	jogadores_na_tela[id].set_nome(nome)

func _on_jogador_atacou(id, dir):
	if jogadores_na_tela.has(id):
		jogadores_na_tela[id].atacar(dir)
		
func _on_knockback(id, direcao):
	if jogadores_na_tela.has(id):
		jogadores_na_tela[id].aplicar_knockback(direcao)

func _on_jogador_curou(id):
	print("on_jogador_curou")
	if jogadores_na_tela.has(id):
		jogadores_na_tela[id].animar_cura()


func _on_jogador_saiu(id):
	if jogadores_na_tela.has(id):
		jogadores_na_tela[id].queue_free() 
		jogadores_na_tela.erase(id)

func _on_jogador_morreu(id):
	if jogadores_na_tela.has(id):
		jogadores_na_tela[id].morrer()
		
func _on_item_destruido(nome_item):
	print("Rede mandou destruir: ", nome_item)

	# Procura o nó pelo nome dentro da cena atual (recursive = true procura em filhos e netos)
	var item = find_child(nome_item, true, false)

	if item:
		item.queue_free()
	else:
		print("Não achei o item pra destruir: ", nome_item)
