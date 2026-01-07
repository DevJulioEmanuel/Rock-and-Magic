extends CPUParticles2D

func _ready():
	# --- CONFIGURAÇÃO VISUAL ---
	z_index = 100

	# MANTIVE GIGANTE PRA GENTE VER (DEPOIS VOCÊ DIMINUI)
	scale_amount_min = 10.0 
	scale_amount_max = 15.0

	amount = 32
	one_shot = true
	explosiveness = 1.0
	lifetime = 0.5 # Garante que dura meio segundo

	# --- FÍSICA ---
	gravity = Vector2(0, 0)
	direction = Vector2(0, 0)
	spread = 180.0
	initial_velocity_min = 100.0
	initial_velocity_max = 200.0

	# --- COR ---
	color = Color(1, 0, 0, 1) 

	# --- INICIAR ---
	emitting = true 

	# --- SE MATA QUANDO ACABAR (APITO DO MICROONDAS) ---
	finished.connect(queue_free)
