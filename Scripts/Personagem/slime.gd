extends CharacterBody2D

var vida = 5
var _play_ref = null
var SPEED = 20
var isdead = false
var player_in_area = false
#KNOCKBACK
var knockback_vector = Vector2.ZERO
var knockback_speed = 150
var knockback_time = 0.15
var knockback_timer = 0.0

func _physics_process(_delta: float) -> void:
	if isdead:
		return
		
	if knockback_timer>0:
		knockback_timer -= _delta
		var movimento = knockback_vector * _delta
		move_and_collide(movimento)
	else:
		knockback_vector = Vector2.ZERO
		
		
	if _play_ref != null and not _play_ref.isdead:
		var _direction: Vector2 = global_position.direction_to(_play_ref.global_position)
		var _distance: float = global_position.distance_to(_play_ref.global_position)
		velocity = _direction * SPEED
		$AnimatedSprite2D.play("move")
		move_and_slide()
	else:
		$AnimatedSprite2D.play("idle")
		
	
func death() -> void:
	SPEED = 0
	if !isdead:
		$AnimatedSprite2D.play("death")
	isdead = true

func dano(forca: int, direcao: Vector2) -> void:
	vida -= forca
	knockback(direcao)
	if vida<=0:
		death()

func knockback(direcao: Vector2) -> void:
	knockback_vector = direcao.normalized() * knockback_speed
	knockback_timer = knockback_time
	
	
func _on_detection_area_body_entered(body:Node) -> void:
	if body.is_in_group("character"):
		_play_ref = body
	pass


func _on_detection_area_body_exited(body:CharacterBody2D) -> void:
	if body.is_in_group("character"):
		_play_ref = null
	pass # Replace with function body.


func _on_damage_body_entered(body: Node2D) -> void:
	if isdead:
		return
	if body.is_in_group("character"):
		damage(body)
		
		
func damage(body: Node2D):
	var direcao = (body.global_position - global_position).normalized()
	body.hit(2, direcao)
	player_in_area = true
	$Damage/DamageTimer.start()
	
func _on_damage_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("character"):
		player_in_area = false
		$Damage/DamageTimer.stop()



func _on_damage_timer_timeout() -> void:
	if player_in_area:
			get_node("/root/Principal/CharacterBody2D").hit(2, 0, 0)
