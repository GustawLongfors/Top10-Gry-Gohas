extends KinematicBody2D

export (int) var speed = 30
export (int) var gravity = 15

var velocity = Vector2()
var facing = 1
var fly_direction = 1

func _physics_process(delta):
	$Sprite.flip_h = velocity.x < 0
	$Sprite.play("Fly")
	velocity.y += gravity * fly_direction
	velocity.x = facing * speed

	velocity = move_and_slide(velocity, Vector2(0, -1))
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.name == "PLAYER":
			collision.collider.hurt()
		if collision.normal.x != 0:
			facing = sign(collision.normal.x)
		if collision.normal.y != 0:
			fly_direction = sign(collision.normal.y)
	if position.y > 10000:
		queue_free()
	
func take_damage():
	$Sprite.play('Die')
	set_physics_process(false)
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Die':
		queue_free()
