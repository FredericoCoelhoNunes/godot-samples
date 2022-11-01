extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 120
const FRICTION = 500

var velocity = Vector2.ZERO
	
func _physics_process(delta):
	# Get the current "joystick" direction normalized to 1
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# Accelerate towards MAX_SPEED in that direction by an amount that
	# is proportional to delta
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Move (and slide, in case of a collision) in the velocity direction. Delta is handled
    # internally.
	velocity = move_and_slide(velocity)
	
	
