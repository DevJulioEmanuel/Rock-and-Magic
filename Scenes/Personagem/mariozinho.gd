extends CharacterBody2D

@export_category("Variables")
@export var _move_speed : float = 100.0
@export var _acceleration : float = 0.4
@export var _friction : float = 0.3
@onready var colisao_espada = $EspadaHitbox/CollisionShape2D
@onready var audioPassos = $AudioStreamPlayer2D
@onready var barra_vida = $BarraVida
@onready var botao_respawn = $CanvasLayer/BotaoRespawn
@onready var camera = $Camera2D
@onready var sfx_ataque = $"SfxHit-Ar"
@onready var sfx_hit = $"SfxHit-Corpo"
var tilemap_chao: Node

var vida = 5
var atacando: bool = false
var ultima_tecla
var isdead: bool = false
var em_knockback = false


var _network_timer: float = 0.0
const NETWORK_TICK_RATE: float = 0.05 
# -------------------------------

#nkockback
var knockback_vector = Vector2.ZERO
var knockback_speed = 130
var knockback_time = 0.3
var knockback_timer = 0.0
var is_slowed: bool = false
var slowtimer = 0.0


func _ready() -> void:
	set_process(true)
	set_physics_process(true)
	tilemap_chao = get_tree().current_scene.find_child("ground", true, false)

	colisao_espada.disabled = true
	$AnimatedSprite2D.play("parado_down")
	$EspadaHitbox.monitoring = false
	# Conecta sinais se existirem
	if Network.has_signal("tomei_dano"):
		Network.tomei_dano.connect(_on_network_damage)
	Network.knockback_aplicado.connect(_on_knockback)
	
	barra_vida.max_value = vida
	barra_vida.value = vida
	
	
func _physics_process(delta: float) -> void:
	if isdead:
		return
	checar_interacao_chao()
	# Lógica de Knockback e Slow
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_vector
		move_and_slide()
	else:
		if em_knockback:
			velocity = Vector2.ZERO
			em_knockback = false

		if is_slowed:
			slowtimer -= delta
			if slowtimer <= 0:
				is_slowed = false
				
		_move()
		move_and_slide()

	# --- LÓGICA DE ENVIO LIMITADO (MODIFICADO) ---
	_network_timer += delta
	
	# Só entra aqui se o tempo passou E se o player está se movendo
	if _network_timer >= NETWORK_TICK_RATE:
		_network_timer = 0.0

		if velocity.length() > 0 or knockback_timer > 0:
			Network.enviar_mensagem({
				"cmd": "MOVE",
				"x": global_position.x,
				"y": global_position.y,
				"anim": $AnimatedSprite2D.animation,
				"flip": $AnimatedSprite2D.flip_h
			})

	# ---------------------------------------------

	if Input.is_action_just_pressed("action"):
		_action()
		
func hit(dano: int) -> void:
	camera.aplicar_shake(5.0)
	vida -= dano
	spawnar_sangue()
	barra_vida.value = vida
	print("Vida atual: ", vida, " / Valor da Barra: ", barra_vida.value)
	sfx_hit.pitch_scale = randf_range(0.8, 1.0) # Um pouco mais grave quando a gente apanha
	sfx_hit.play()
	is_slowed = true
	slowtimer = 1.5
	for i in range (2):
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = Color.TRANSPARENT
		await get_tree().create_timer(0.09).timeout
	$AnimatedSprite2D.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	if vida <= 0 :
		if not isdead:
			$AnimatedSprite2D.play("death")
			Network.enviar_mensagem({"cmd": "DIE"})
			botao_respawn.visible = true
		isdead = true
		
		
func _action() -> void:
	if global.player_in_npc == true:
		return
		
	sfx_ataque.pitch_scale = randf_range(0.9, 1.1)
	sfx_ataque.play()
	atacando = true
	velocity.x = 0
	velocity.y = 0
	$EspadaHitbox.monitoring = true
	colisao_espada.disabled = false
	
	Network.enviar_mensagem({
		"cmd": "ATK",
		"dir": ultima_tecla
	})
	# ------------------------------------------------

	match ultima_tecla:
		"down":
			$AnimatedSprite2D.play("atack_down")
		"up":
			$AnimatedSprite2D.play("atack_up")
		"right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("atack_right")
		"left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("atack_right")
			
	await $AnimatedSprite2D.animation_finished
	$EspadaHitbox.monitoring = false
	colisao_espada.disabled = true
	atacando = false
	

func _on_network_damage(dano, agressor_id, direcao_do_hit):
	hit(dano)
	
func knockback(direcao: Vector2):
	knockback_vector = direcao.normalized() * knockback_speed
	knockback_timer = knockback_time
	
func _on_knockback(id, direcao):
	if id != Network.meu_id:
		return
	em_knockback = true
	knockback(direcao)

	
	
func _move() -> void:
	if global.dialog_active == true:
		velocity.x = 0
		velocity.y = 0
		return
	if is_slowed:
		_move_speed = 25
	else:
		_move_speed = 55.0
	
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	move_sound(_direction)
	if atacando:
		return
	if _direction != Vector2.ZERO:
		velocity.x = lerp(velocity.x, _direction.x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.y * _move_speed, _acceleration)
		if _direction.x < 0:
			$AnimatedSprite2D.flip_h = false
			ultima_tecla = "left"
			$AnimatedSprite2D.play("left")    
			$EspadaHitbox.position = Vector2(-4, 3)
			$EspadaHitbox.rotation = 80
		elif _direction.x > 0:
			$AnimatedSprite2D.flip_h = true
			ultima_tecla = "right"
			$AnimatedSprite2D.play("right")
			$EspadaHitbox.position = Vector2(8, 3)
			$EspadaHitbox.rotation = -80
		elif _direction.y < 0:
			$AnimatedSprite2D.play("up")
			ultima_tecla = "up"
			$EspadaHitbox.position = Vector2(1, -1)
			$EspadaHitbox.rotation = 0
		elif _direction.y > 0:
			$AnimatedSprite2D.play("down")
			ultima_tecla = "down"
			$EspadaHitbox.position = Vector2(1, 13)
			$EspadaHitbox.rotation = 0

	else:
		velocity.x = lerp(velocity.x, 0.0 , _friction)
		velocity.y = lerp(velocity.y, 0.0, _friction)
		if ultima_tecla == "left":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("parado_left")
		elif  ultima_tecla == "right":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("parado_right")
		elif  ultima_tecla == "up":
			$AnimatedSprite2D.play("parado_up")
		elif  ultima_tecla == "down":
			$AnimatedSprite2D.play("parado_down")

func move_sound(direction) -> void:
	if direction == Vector2.ZERO or atacando==true:
		
		audioPassos.stop()
	elif direction != Vector2.ZERO and not audioPassos.playing:
		audioPassos.play()
	

func _on_botao_respawn_pressed() -> void:
	vida = 5
	isdead = false
	
	barra_vida.value = vida
	if has_node("Label"): $Label.text = str(vida)
	
	$AnimatedSprite2D.play("parado_down")
	$AnimatedSprite2D.modulate = Color.WHITE
	
	botao_respawn.visible = false

	Network.enviar_mensagem({
		"cmd": "RESPAWN",
		"x": global_position.x,
		"y": global_position.y
	})
	
func spawnar_sangue():
	var sangue = CPUParticles2D.new()

	sangue.amount = 18
	sangue.one_shot = true
	sangue.explosiveness = 0.5
	sangue.lifetime = 0.3
	sangue.z_index = 100 

	sangue.direction = Vector2(0, 0)
	sangue.spread = 180.0
	sangue.gravity = Vector2(0, 0) 
	sangue.initial_velocity_min = 100.0
	sangue.initial_velocity_max = 200.0

	sangue.scale_amount_min = 2.0 
	sangue.scale_amount_max = 2.0
	sangue.color = Color(1, 0, 0, 1)
	
	sangue.global_position = global_position

	get_tree().root.add_child(sangue)
	sangue.emitting = true
	sangue.finished.connect(sangue.queue_free)
	
func checar_interacao_chao():
	if tilemap_chao == null: return
	var posicao_grid = tilemap_chao.local_to_map(global_position)
	var source_id = tilemap_chao.get_cell_source_id(posicao_grid)
	var atlas_coords = tilemap_chao.get_cell_atlas_coords(posicao_grid)
	print("Estou pisando no Tile: ", atlas_coords)
	var ID_ARQUIVO_COGUMELO = 1
	var POSICAO_COGUMELO = Vector2i(0, 3)
	if source_id == ID_ARQUIVO_COGUMELO and atlas_coords == POSICAO_COGUMELO:
		var id_do_tile = tilemap_chao.get_cell_source_id(posicao_grid)

		if id_do_tile != -1:
			var curou = curar(1) 
			
			if curou:
				tilemap_chao.set_cell(posicao_grid, -1)
				print("Comi o cogumelo do chão!")
				
func curar(quantidade: int) -> bool:
	if vida >= 5:
		return false 
		
	vida += quantidade
	
	Network.enviar_mensagem({
		"cmd": "cura",
	})
	barra_vida.value = vida
	if has_node("Label"): $Label.text = str(vida)

	modulate = Color(1.5, 1.5, 0, 1) 
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)

	print("Player curado! Vida: ", vida)
	return true
