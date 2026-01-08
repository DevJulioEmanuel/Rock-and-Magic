extends Control

@onready var input_ip = $VBoxContainer/InputIP
@onready var input_sala = $VBoxContainer/InputSala
@onready var input_nome = $VBoxContainer/input_name
@onready var botao = $VBoxContainer/Button

func _ready():
	botao.pressed.connect(_on_botao_pressed)
	Network.conexao_falhou.connect(_on_falha_conexao)
	Network.conectado_ao_servidor.connect(_on_conectado)

func _on_botao_pressed():
	var ip = input_ip.text
	var sala = input_sala.text
	var nome = input_nome.text
	var porta = ""
	if sala == "" or nome == "":
		return
	if ":" in ip:
		var partes = ip.split(":")
		ip = partes[0] 
		porta = int(partes[1])
	
	botao.disabled = true
	botao.text = "Conectando..."
	Network.conectar_ao_servidor(ip, porta, sala, nome)

func _on_conectado():
	print("Trocando para o mundo do jogo...")
	get_tree().change_scene_to_file("res://Scenes/Fazenda/principal.tscn") 
	
func _on_falha_conexao():
	$Label.visible = true
	$Label.text = "Falha ao conectar!"

	await get_tree().create_timer(2.0).timeout

	$Label.visible = false 
	botao.disabled = false
	botao.text = "Conectar"
