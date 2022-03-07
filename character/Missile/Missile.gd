extends KinematicBody2D

export (int) var gravity = -150
var run_speed = 250

enum {IDLE, RUN, EXPLODE}
var state
var anim
var new_anim
var velocity = Vector2()

func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(run_speed, 0)	

func _ready():
	#$WindupExploSound.playing()
	change_state(RUN)

func _physics_process(delta):
	if state != EXPLODE:
		$Sprite.flip_h = velocity.x < 0
	velocity.y -= gravity * delta
	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.name == 'Danger':
			Explode()
			
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
			queue_free()

func Explode():
	if state != EXPLODE:
		$WindupExploSound.stop()
		change_state(EXPLODE)

func _on_Timer_timeout():
	Explode()

func _on_ExplosionRadius_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage()
