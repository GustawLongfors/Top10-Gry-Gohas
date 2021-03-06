extends KinematicBody2D


export (int) var gravity = -150
var run_speed = 250

enum {IDLE, RUN, EXPLODE}
var state
var anim
var new_anim
var velocity = Vector2()
var facing = 1

func start(pos, dir):
	position = pos

	if dir == 1:
		facing = 1
	elif dir == -1:
		facing = -1
	change_state(RUN)

func _physics_process(delta):
	if state != EXPLODE:
		$Sprite.flip_h = velocity.x < 0
	velocity.y -= gravity * delta
	velocity.x = facing * run_speed
	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
		
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.is_in_group('enemy'):
			Explode()
		if collision.normal.x != 0:
			facing = sign(collision.normal.x)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'Idle'
		RUN:
			new_anim = 'Run'
		EXPLODE:
			new_anim = 'Explode'
			velocity.y = 0
			velocity.x = 0
			$ExplodeSound.play()
			$ExplosionParticles.visible = true
			$ExplosionParticles.emitting = true
			$ExplosionRadius/ExplCollisionShape2D.disabled = false
			$DelayTimer.start()

func Explode():
	$WindupExploSound.stop()
	change_state(EXPLODE)

func _on_Timer_timeout():
	Explode()

func _on_ExplosionRadius_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage()
		
func _on_DelayTimer_timeout():
	queue_free()
