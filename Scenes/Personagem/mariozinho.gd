extends CharacterBody2D

@export_category("Variables")
@export var _move_speed : float = 100.0
@export var _acceleration : float = 0.4
@export var _friction : float = 0.3

@onready var audioPassos = $AudioStreamPlayer2D
var vida = 10
var atacando: bool = false
var ultima_tecla
var isdead: bool = false

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
	$AnimatedSprite2D.play("parado_down")
	$EspadaHitbox.monitoring = false
	
	
func _physics_process(delta: float) -> void:
	if isdead:
		return
	if knockback_timer>0:
		knockback_timer -= delta
		var movimento = knockback_vector * delta
		move_and_collide(movimento)
	else:
		knockback_vector = Vector2.ZERO
	if is_slowed:
		slowtimer -= delta
		if slowtimer <= 0:
			is_slowed = false
	_move()
	
	move_and_slide()

	if Input.is_action_just_pressed("action"):
		_action()
		
func hit(dano: int, direcao: Vector2) -> void:
	vida -= dano
	is_slowed = true
	slowtimer = 1.5
	knockback(direcao)
	for i in range (2):
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = Color.TRANSPARENT
		await get_tree().create_timer(0.09).timeout
	$AnimatedSprite2D.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	if vida < 0 :
		if not isdead:
			$AnimatedSprite2D.play("death")
		isdead = true
		
		
func _action() -> void:
	if global.player_in_npc == true:
		return
	atacando = true
	velocity.x = 0
	velocity.y = 0
	$EspadaHitbox.monitoring = true
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
	atacando = false
	
func knockback(direcao: Vector2):
	knockback_vector = direcao.normalized() * knockback_speed
	knockback_timer = knockback_time
	
	
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
	
