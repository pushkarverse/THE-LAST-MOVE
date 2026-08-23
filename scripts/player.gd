extends CharacterBody2D

# ──────────────────────────────────────────
#  Movement constants
# ──────────────────────────────────────────
const SPEED         : float = 90.0    # px/s horizontal
const JUMP_VELOCITY : float = -240.0  # px/s upward
const GRAVITY       : float = 650.0   # px/s²
const MAX_FALL      : float = 500.0   # terminal velocity
const COYOTE_TIME   : float = 0.10    # seconds of grace after leaving a floor
const JUMP_BUFFER   : float = 0.10    # seconds to buffer a jump before landing

# ──────────────────────────────────────────
#  State
# ──────────────────────────────────────────
var _coyote_timer    : float = 0.0
var _jump_buf_timer  : float = 0.0
var _step_timer      : float = 0.0
var _was_on_floor    : bool  = false
var _is_dead         : bool  = false
var _air_jumps_used  : int   = 0     # counts mid-air jumps consumed this airtime

## Set to true by the mystery box to unlock double jump
var has_double_jump  : bool  = false

## Room sets this before adding player to scene tree
var spawn_position   : Vector2 = Vector2.ZERO

# ──────────────────────────────────────────
#  Signals
# ──────────────────────────────────────────
signal died
signal reached_exit

# ──────────────────────────────────────────
#  Child nodes
# ──────────────────────────────────────────
@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("player")   # so mystery boxes and hazards can detect the player by group
	if spawn_position != Vector2.ZERO:
		position = spawn_position
	anim_sprite.play("idle")


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_apply_gravity(delta)
	_handle_coyote(delta)
	_handle_jump_buffer(delta)
	_handle_jump()
	_handle_horizontal(delta)
	move_and_slide()
	_handle_footsteps(delta)
	_update_animation()
	_check_fallen_out()


# ──────────────────────────────────────────
#  Physics helpers
# ──────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0


func _handle_coyote(delta: float) -> void:
	if _was_on_floor and not is_on_floor():
		_coyote_timer = COYOTE_TIME
	elif is_on_floor():
		_coyote_timer = 0.0
		_air_jumps_used = 0    # Reset air jumps when back on ground
	if _coyote_timer > 0.0:
		_coyote_timer -= delta
	_was_on_floor = is_on_floor()


func _handle_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buf_timer = JUMP_BUFFER
	if _jump_buf_timer > 0.0:
		_jump_buf_timer -= delta


func _handle_jump() -> void:
	var can_jump := is_on_floor() or _coyote_timer > 0.0
	if _jump_buf_timer > 0.0 and can_jump:
		velocity.y      = JUMP_VELOCITY
		_coyote_timer   = 0.0
		_jump_buf_timer = 0.0
		_air_jumps_used = 0
		AudioManager.play("select", -6.0)   # light jump sound from existing SFX
		return

	# Double jump — only when airborne, power-up collected, and not yet used
	if has_double_jump and not is_on_floor() and _coyote_timer <= 0.0:
		if Input.is_action_just_pressed("jump") and _air_jumps_used < 1:
			_air_jumps_used += 1
			velocity.y = JUMP_VELOCITY * 0.85   # slightly weaker than ground jump
			_jump_buf_timer = 0.0
			AudioManager.play("select", -3.0, 1.3)  # slightly higher pitch = air jump feel
			return

	# Variable-height jump: release early to cut upward speed
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45


func _handle_horizontal(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 3.0 * delta)


func _handle_footsteps(delta: float) -> void:
	if is_on_floor() and absf(velocity.x) > 5.0:
		_step_timer -= delta
		if _step_timer <= 0.0:
			AudioManager.play("walk", -18.0) # Play quietly
			_step_timer = 0.28 # Sensible footstep interval
	else:
		# Reset timer when stopped or in air, so first step plays immediately upon moving
		_step_timer = 0.0



# ──────────────────────────────────────────
#  Animation
# ──────────────────────────────────────────
func _update_animation() -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir > 0.0:
		anim_sprite.flip_h = false
	elif dir < 0.0:
		anim_sprite.flip_h = true

	var anim : String
	if not is_on_floor():
		anim = "jump"
	elif absf(velocity.x) > 5.0:
		anim = "walk"
	else:
		anim = "idle"

	if anim_sprite.animation != anim:
		anim_sprite.play(anim)


# ──────────────────────────────────────────
#  Damage / Death / Respawn
# ──────────────────────────────────────────
func take_damage() -> void:
	if _is_dead:
		return
	die()


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity  = Vector2.ZERO
	anim_sprite.modulate = Color(1.0, 0.3, 0.3, 0.8)
	AudioManager.play("death")
	emit_signal("died")


func respawn(pos: Vector2) -> void:
	position             = pos
	velocity             = Vector2.ZERO
	_is_dead             = false
	_coyote_timer        = 0.0
	_jump_buf_timer      = 0.0
	_air_jumps_used      = 0
	has_double_jump      = false   # power-up resets on death (must re-collect each life)
	anim_sprite.modulate = Color.WHITE
	anim_sprite.play("idle")


## Kill zone — fell below the visible room
func _check_fallen_out() -> void:
	if position.y > 700.0:
		die()
