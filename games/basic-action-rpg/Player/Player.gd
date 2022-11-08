extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 120
export var ROLL_SPEED = 150
export var FRICTION = 1900

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	# move_and_slide allows sliding along the collision surface rather than "grinding" or having
	# friction against it. This function takes a velocity and internally handles the delta
	# Returns the updated velocity after the collisions
	velocity = move_and_slide(velocity)
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE

func attack_animation_finished():
	state = MOVE

func move_state(delta):
	# Everything is multiplied by delta so that the movement is tied to real-time rather than game time.
	# Delta is the time the last frame took to run. If we experience lag, we don't want the character
	# to move slower but rather to move at the same speed (which can possibly cause some jumps but
	# it's the better alternative)
	# "whenever we have something that changes over time, if it's tied to the frame rate, we need to
	# multiply it by delta"
	
	# Get the current "joystick" direction normalized to 1
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# If there's a direction, accelerate towards max. speed in that direction by an amount that
	# is proportional by how long it took for the last frame to be processed (so if the last frame lagged
	# a lot and took 2x time to process, assuming that we kept the joystick pointed in this direction,
	# our character should have accelerated twice as much compared to a "normal" frame)
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector # this makes it so roll vector is never set to zero, so we can roll even after stopping
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		# We set the blend position for the attack's BlendSpace2D *immediately before* the
		# animation triggers. This is because we don't want the player to be able to change anything mid
		# animation
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# move_toward -> make velocity approach (0, 0) by a small amount each frame if we aren't
		# pressing anything
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Finally, move in the direction of velocity by an amount v*delta (move and collide takes an actual
	# delta_x as argument
	# move_and_collide(velocity * delta)

	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK 
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
