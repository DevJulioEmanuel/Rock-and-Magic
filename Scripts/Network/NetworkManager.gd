extends Node

signal conectado_ao_servidor
signal jogador_moveu(id, x, y, anim, flip, nome)
signal jogador_atacou(id, dir)
signal jogador_entrou(id)
signal jogador_saiu(id)
signal tomei_dano(dano, id_agressor, vetor_empurrao)
signal jogador_morreu(id)
signal knockback_aplicado(id, direcao)
signal jogador_curou(id)
signal item_destruido(nome_do_item)
signal nova_mensagem_feed(texto)
signal conexao_falhou

var meu_id := -1


var socket := StreamPeerTCP.new()
var status = 0
var buffer = ""
var tempo_tentativa: float = 0.0
const TIMEOUT_LIMITE: float = 5.0

var sala_desejada = ""
var nome_jogador = ""

func conectar_ao_servidor(ip_digitado, porta, nome_sala, nome):
	sala_desejada = nome_sala
	nome_jogador = nome
	print("Conectando em: ", ip_digitado)
	tempo_tentativa = 0.0
	socket.connect_to_host(ip_digitado, porta)
	socket.set_no_delay(true)

func _process(delta):
	socket.poll()
	var novo_status = socket.get_status()
	if novo_status == StreamPeerTCP.STATUS_CONNECTING:
		tempo_tentativa += delta        
		if tempo_tentativa >= TIMEOUT_LIMITE:
			print("❌ TIMEOUT: O servidor demorou demais.")
			socket.disconnect_from_host()
			emit_signal("conexao_falhou")
			status = StreamPeerTCP.STATUS_NONE
			return

	elif novo_status == StreamPeerTCP.STATUS_ERROR:
		print("❌ ERRO IMEDIATO: Não foi possível conectar.")
		socket.disconnect_from_host()
		emit_signal("conexao_falhou")
		status = StreamPeerTCP.STATUS_NONE
		return
	if novo_status != status:
		status = novo_status
		if status == StreamPeerTCP.STATUS_CONNECTED:
			print("Conectado ao Servidor com Sucesso!")
			emit_signal("conectado_ao_servidor")
			enviar_mensagem({"cmd": "JOIN", "nome_sala": sala_desejada, "nome": nome_jogador})
			
	if status == StreamPeerTCP.STATUS_CONNECTED:
		_ler_dados()
		
func _ler_dados():
	if socket.get_available_bytes() > 0:
		var bytes = socket.get_utf8_string(socket.get_available_bytes())
		buffer += bytes
		
		while "\n" in buffer:
			var split = buffer.split("\n", true, 1)
			var msg_json = split[0]
			buffer = split[1]
			_processar_pacote(msg_json)
	
func desconectar_do_servidor():
	print("Encerrando conexão...")
	enviar_mensagem({"cmd": "jogador_desconectou", "id_jogador": meu_id})
	socket.disconnect_from_host() 
	status = StreamPeerTCP.STATUS_NONE 
	meu_id = -1 
	buffer = "" 
	sala_desejada = ""
	nome_jogador = ""

func _processar_pacote(json_str):
	var json = JSON.new()
	var erro = json.parse(json_str)
	if erro != OK: return
	
	var dados = json.get_data()
	print("O CLIENTE RECEBEU O COMANDO: ", dados["cmd"])
	
	if dados["cmd"] == "MOVE":
		emit_signal("jogador_moveu", dados["id"], dados["x"], dados["y"], dados["anim"], dados["flip"], dados.get("nome", "Desconhecido"))
	
	elif dados["cmd"] == "ATK":
		emit_signal("jogador_atacou", dados["id"], dados["dir"])
		
	elif dados["cmd"] == "JOIN_OK":
		meu_id = dados["id"]
		
	elif dados["cmd"] == "TAKE_DMG":
		var dx = dados.get("dir_x", 0.0)
		var dy = dados.get("dir_y", 0.0)
		var vetor = Vector2(dx, dy)
		emit_signal("tomei_dano", dados["dano"], dados["agressor"], vetor)
		
	elif dados["cmd"] == "KNOCKBACK":
		var dir = Vector2(dados["dir_x"], dados["dir_y"])
		emit_signal("knockback_aplicado", dados["id"], dir)
		
	elif dados["cmd"] == "PLAYER_DISCONNECT":
		emit_signal("jogador_saiu", dados["id"])
		
	elif dados["cmd"] == "DIE":
		emit_signal("jogador_morreu", dados["id"])
		
	elif dados["cmd"] == "cura":
		emit_signal("jogador_curou", dados["id"])
		
	elif dados["cmd"] == "destruir_item":
		emit_signal("item_destruido", dados["nome_item"])
	
	elif dados["cmd"] == "FEED":
		emit_signal("nova_mensagem_feed", dados["msg"])
		
func enviar_mensagem(dict_msg):
	if status == StreamPeerTCP.STATUS_CONNECTED:
		var txt = JSON.stringify(dict_msg) + "\n"
		socket.put_data(txt.to_utf8_buffer())
	
