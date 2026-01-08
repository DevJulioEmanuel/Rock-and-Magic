extends Node2D

const PORTA = 5000
var servidor := TCPServer.new()
var clientes = {} 

func _ready():
	var erro = servidor.listen(PORTA)
	if erro != OK:
		print("Erro ao iniciar servidor: ", erro)
		return
	print("Servidor rodando na porta: ", PORTA)
	print("Aguardando conexões...")
	

func _process(delta):
	if servidor.is_connection_available():
		var novo_socket = servidor.take_connection()
		_aceitar_cliente(novo_socket)
	
	_processar_clientes()
	
func _aceitar_cliente(socket: StreamPeerTCP):
	var id = Time.get_ticks_msec()

	clientes[id] = {
		"socket": socket,
		"sala": "",
		"buffer": "" 
	}
	print("Novo cliente conectado! ID: ", id)
	
func _processar_clientes():
	for id in clientes.keys():
		var cliente = clientes[id]
		var socket = cliente["socket"]
		var status = socket.get_status()

		if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			print("Cliente desconectou: ", id)
			_remover_cliente(id)
			continue
		
		if socket.get_available_bytes() > 0:
			var bytes = socket.get_utf8_string(socket.get_available_bytes())
			
			cliente["buffer"] += bytes
			
			#NAO ENTENDI ESSA PARTE
			while "\n" in cliente["buffer"]:
				var split = cliente["buffer"].split("\n", true, 1)
				var mensagem_crua = split[0]
				cliente["buffer"] = split[1] 
				
				_interpretar_comando(id, mensagem_crua)
		
func _interpretar_comando(id_remetente, json_str):
	var json = JSON.new()
	var parse_result = json.parse(json_str)
	
	if parse_result != OK:
		print("Erro ao ler JSON: ", json_str)
		return
		
	var dados = json.get_data()
	
	# Comando: ENTRAR NA SALA
	if dados.has("cmd") and dados["cmd"] == "JOIN":
		clientes[id_remetente]["sala"] = dados["nome_sala"]
		clientes[id_remetente]["nome"] = dados.get("nome", "Desconhecido")
		print("Cliente ", clientes[id_remetente]["nome"], ":", id_remetente, " entrou na sala: ", dados["nome_sala"])
		_enviar_mensagem(id_remetente, {"cmd": "JOIN_OK", "id": id_remetente})
		var msg_entrada = clientes[id_remetente]["nome"] + " entrou na sala."
		_broadcast_sala(dados["nome_sala"], {"cmd": "FEED", "msg": msg_entrada}, -1)
	# Comando: MOVIMENTO (Ou qualquer atualização de jogo)
	elif dados.has("cmd") and dados["cmd"] == "MOVE":
		var sala_atual = clientes[id_remetente]["sala"]
		if sala_atual == "":
			return
		dados["id"] = id_remetente
		dados["nome"] = clientes[id_remetente].get("nome", "Desconhecido")
		_broadcast_sala(sala_atual, dados, id_remetente)
	
	# Comando: AÇÃO (Ataque)
	elif dados.has("cmd") and dados["cmd"] == "ATK":
		var sala_atual = clientes[id_remetente]["sala"]
		dados["id"] = id_remetente
		_broadcast_sala(sala_atual, dados, id_remetente)
		
	# Comando: DAR DANO (Ataque)
	elif dados.has("cmd") and dados["cmd"] == "HIT":
		var alvo = int(dados["target_id"])
		var dano = dados["dano"]
		var dx = dados.get("dir_x", 0.0)
		var dy = dados.get("dir_y", 0.0)

		var sala = clientes[id_remetente]["sala"]

		_enviar_mensagem(alvo, {
			"cmd": "TAKE_DMG",
			"dano": dano,
			"agressor": id_remetente
		})
		_broadcast_sala(sala, {
			"cmd": "KNOCKBACK",
			"id": alvo,
			"dir_x": dx,
			"dir_y": dy
		}, -1)

	#COMANDO MORRER, DIE
	elif dados.has("cmd") and dados["cmd"] == "DIE":
		dados["id"] = id_remetente 
		_broadcast_sala(clientes[id_remetente]["sala"], dados, id_remetente)
		var nome_vitima = clientes[id_remetente].get("nome", "Alguém")
		var id_assassino = int(dados.get("killer_id", -1))
		var msg_morte = ""

		if id_assassino != -1 and clientes.has(id_assassino):
			var nome_assassino = clientes[id_assassino].get("nome", "Misterioso")
			msg_morte = nome_assassino + " eliminou " + nome_vitima
		else:
			msg_morte = nome_vitima + " foi de base."            
		_broadcast_sala(clientes[id_remetente]["sala"], {"cmd": "FEED", "msg": msg_morte}, -1)
		
	#COMANDO RESPAWN
	elif dados.has("cmd") and dados["cmd"] == "RESPAWN":
		dados["id"] = id_remetente
		_broadcast_sala(clientes[id_remetente]["sala"], dados, id_remetente)
	
	elif dados.has("cmd") and dados["cmd"] == "cura":
		print("ativeii a cura")
		dados["id"] = id_remetente
		_broadcast_sala(clientes[id_remetente]["sala"], dados, id_remetente)
		
	elif dados.has("cmd") and dados["cmd"] == "destruir_item":
		print("ativei a cura")
		dados["id"] = id_remetente
		_broadcast_sala(clientes[id_remetente]["sala"], dados, id_remetente)
		
	elif dados.has("cmd") and dados["cmd"] == "jogador_desconectou":
		var id_jogador = int(dados.get("id_jogador", -1))
		var msg = ""
		var nome_jogador = clientes[id_jogador].get("nome", "Misterioso")
		msg = nome_jogador + " desconectou da sala " + clientes[id_jogador]["sala"]
				 
		_broadcast_sala(clientes[id_remetente]["sala"], {"cmd": "FEED", "msg": msg}, -1)
		

		
func _broadcast_sala(sala, mensagem_dict, id_remetente):
	for id in clientes:
		if clientes[id]["sala"] == sala and id != id_remetente:
			_enviar_mensagem(id, mensagem_dict)
	
func _enviar_mensagem(id_destino, dados_dict):
	if not clientes.has(id_destino): return
	
	var socket = clientes[id_destino]["socket"]
	var json_str = JSON.stringify(dados_dict)
	
	socket.put_data((json_str + "\n").to_utf8_buffer())
	
func _remover_cliente(id):
	var sala = clientes[id]["sala"]
	if sala != "":
		_broadcast_sala(sala, {"cmd": "PLAYER_DISCONNECT", "id": id}, id)
	
	if clientes.has(id):
		clientes.erase(id)
