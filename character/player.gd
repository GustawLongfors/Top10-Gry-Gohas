extends KinematicBody2D

signal life_changed
signal dead

const ChickenMissile = preload("res://character/Missile/Missile.tscn")

export (int) var run_speed = 100
export (int) var jump_speed = -125
export (int) var gravity = -150
export (int) var fall_speed = 400
export (int) var acceleration = 7

enum {IDLE, RUN, JUMP, ATTACK1, ATTACK2, HURT, DEAD}
var state
var anim
var new_anim
var velocity = Vector2()
var life = 3
var max_jumps = 2
var jump_count = 0

var direction = Vector2.RIGHT	

func _ready():
	change_state(IDLE)

func start(pos):
	position = pos
	show()
	emit_signal('life_changed', life)
	change_state(IDLE)
	
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'Idle'
		RUN:
			new_anim = 'Run'
		HURT:
			new_anim = 'Hurt'
			velocity.y = -75
			velocity.x = -2000 * sign(velocity.x)
			life -= 1
			emit_signal('life_changed', life)
			yield(get_tree().create_timer(0.5), 'timeout')
			change_state(IDLE)
			if life <= 0:
				change_state(DEAD)
		JUMP:
			new_anim = 'Jump'
			jump_count = 1
		ATTACK1:
			new_anim = 'Attack1'
		DEAD:
			hide()
			$CollisionShape2D.disabled = true
			$Timer.start()
			emit_signal('dead')

func get_input():
	if state == HURT:
		return
	velocity.x = 0
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('jump')
	var leftClick = Input.is_action_just_pressed('attack')

	if right:
		velocity.x += run_speed
		$Sprite.flip_h = false
		direction = Vector2.RIGHT
	elif left:
		velocity.x -= run_speed
		$Sprite.flip_h = true
		direction = Vector2.LEFT
	if jump and state == JUMP and jump_count < max_jumps:
		new_anim = 'Jump'
		velocity.y = jump_speed / 1.5
		jump_count += 1
	if jump and is_on_floor():
		$JumpSound.play()
		change_state(JUMP)
		print(JUMP)
		velocity.y = jump_speed
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
		print(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
		print(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)
	if leftClick:
		velocity.x = 0
		change_state(IDLE)
		$Sprite.play("Attack1")
		spawn_Chicken()

func _physics_process(delta):
	get_input()
	velocity.y -= gravity * delta
	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if state == HURT:
		return
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.name == 'Danger':
			hurt()
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		$Particles.emitting = true
	if position.y > 10000:
		change_state(DEAD)
func hurt():
	if state != HURT:
		#$HurtSound.play()
		change_state(HURT)

func _on_Timer_timeout():
	get_tree().change_scene("res://level/gamescene.tscn")

func spawn_Chicken():
	var Chicken = ChickenMissile.instance()
	var rotation
	if direction == Vector2.LEFT:
		rotation = -1
	elif direction == Vector2.RIGHT:
		rotation = 1
	Chicken.start($Position2D.global_position,rotation)
	get_parent().add_child(Chicken)


	
