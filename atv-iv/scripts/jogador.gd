extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	hurt,
	attack
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_golpe: Area2D = $AreaGolpe

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

@export var vida_maxima: int = 5
@export var tempo_hurt: float = 0.4
@export var dano_do_golpe: int = 2
@export var quadro_do_golpe: int = 3

var vida: int
var status: PlayerState
var tempo_no_hurt: float = 0.0
var golpe_aplicado: bool = false
var direcao: float = 1.0

func _ready() -> void:
	vida = vida_maxima
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.hurt:
			hurt_state()
		PlayerState.attack:
			attack_state()

	move_and_slide()

func go_to_idle_state() -> void:
	status = PlayerState.idle
	anim.play("idle")
	anim.modulate = Color(1, 1, 1)
	velocity.x = 0

func go_to_walk_state() -> void:
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state() -> void:
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY

func go_to_hurt_state() -> void:
	status = PlayerState.hurt
	anim.play("hurt")
	anim.modulate = Color(1, 0.4, 0.4)
	tempo_no_hurt = 0.0
	velocity.x = 0
	area_golpe.monitoring = false

func go_to_attack_state() -> void:
	status = PlayerState.attack
	anim.play("attack")
	anim.modulate = Color(1, 1, 1)
	velocity.x = 0
	golpe_aplicado = false
	area_golpe.position.x = abs(area_golpe.position.x) * direcao
	anim.flip_h = direcao < 0
	area_golpe.monitoring = true

func idle_state() -> void:
	update_direction()

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func walk_state() -> void:
	update_direction()
	move()

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state() -> void:
	update_direction()
	move()

	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func hurt_state() -> void:
	tempo_no_hurt += get_physics_process_delta_time()

	if tempo_no_hurt >= tempo_hurt:
		go_to_idle_state()
		return

func attack_state() -> void:
	if not golpe_aplicado and anim.frame >= quadro_do_golpe:
		golpe_aplicado = true

		for corpo in area_golpe.get_overlapping_bodies():
			if corpo != self and corpo.has_method("levar_dano"):
				corpo.levar_dano(dano_do_golpe)

	if not anim.is_playing():
		area_golpe.monitoring = false
		go_to_idle_state()
		return

func update_direction() -> void:
	var direction := Input.get_axis("left", "right")

	if direction > 0:
		direcao = 1.0
		anim.flip_h = false
		area_golpe.position.x = abs(area_golpe.position.x)
	elif direction < 0:
		direcao = -1.0
		anim.flip_h = true
		area_golpe.position.x = -abs(area_golpe.position.x)

func move() -> void:
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func levar_dano(quantidade: int) -> void:
	if status == PlayerState.hurt:
		return

	vida -= quantidade
	print("vida: ", vida)

	if vida <= 0:
		morrer()
		return

	go_to_hurt_state()

func morrer() -> void:
	status = PlayerState.hurt
	area_golpe.monitoring = false
	anim.modulate = Color(1, 1, 1)
	anim.play("death")
	velocity.x = 0
	set_physics_process(false)
