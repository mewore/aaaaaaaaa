class_name Player

extends KinematicBody2D

signal hit()
signal reached_win_area()
signal won()

const WIN_Y: float = 0.0;

onready var ORIGINAL_POSIITON: Vector2 = self.position

# Horizontal
export(float, EXP, 100, 10000, 20) var ACCELERATION: float = 500.0
export(float) var DECELERATION: float = 1000.0
export(float) var MAX_HORIZONTAL_SPEED: float = 100.0

# Vertical
export(float) var JUMP_SPEED: float = 250.0
export(float, 0.0, 0.5) var JUMP_STOP_SPEED_RETENTION: float = 0.5
export(float) var GRAVITY: float = 400.0
export(float) var MAX_FALL_SPEED: float = 270.0

export(int, 0) var JUMP_INPUT_FORGIVENESS: int = 150
var last_wanted_to_jump: int = -JUMP_INPUT_FORGIVENESS
var last_able_to_jump: int = -JUMP_INPUT_FORGIVENESS
var last_jumped: int = -JUMP_INPUT_FORGIVENESS
var is_jumping: bool = false

var motion: Vector2 = Vector2.ZERO

onready var SPRITE: Sprite = $Sprite
onready var ANIMATION_PLAYER: AnimationPlayer = $Sprite/AnimationPlayer
onready var CAMERA: Camera2D = $Camera2D
onready var CAMERA_X_OFFSET: float = CAMERA.position.x
onready var INITIAL_CAMERA_Y_OFFSET: float = CAMERA.position.y
export(float) var CAMERA_LOOK_DOWN_DISTANCE: float = 50.0

onready var STATE_MACHINE: StateMachine = $StateMachine

onready var HURTBOX: Area2D = $Hurtbox
var invulnerable: bool setget set_invulnerable, get_invulnerable

onready var ROOT_ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

func set_invulnerable(new_invulnerable: bool) -> void:
    if HURTBOX:
        HURTBOX.set_deferred("monitorable", not new_invulnerable)

func get_invulnerable() -> bool:
    return not HURTBOX.monitorable if HURTBOX else true

func take_damage(_damage: int = -1) -> void:
    emit_signal("hit")

func megumin() -> void:
    ANIMATION_PLAYER.play("dying")

func celebrate() -> void:
    ROOT_ANIMATION_PLAYER.play("winning")

func win() -> void:
    emit_signal("won")

func move(delta: float) -> void:
    if not is_on_floor():
        motion.y = min(motion.y + GRAVITY * delta, MAX_FALL_SPEED)
    
    # Horizontal movement control
    var x_axis: float = Input.get_action_strength(InputManager.move_right_action) - \
        Input.get_action_strength(InputManager.move_left_action)
    var has_x_axis: bool = not is_zero_approx(x_axis)
    
    ANIMATION_PLAYER.play("walking" if has_x_axis else "idle")
    if has_x_axis:
        SPRITE.flip_h = x_axis < 0
    
    CAMERA.position.x = CAMERA_X_OFFSET * x_axis * abs(self.motion.x) / MAX_HORIZONTAL_SPEED
    
    var look_down_axis: float = Input.get_action_strength("look_down")
    CAMERA.position.y = INITIAL_CAMERA_Y_OFFSET + look_down_axis * CAMERA_LOOK_DOWN_DISTANCE
    
    if not has_x_axis or (x_axis > 0) != (motion.x > 0):
        motion.x = max(motion.x - DECELERATION * delta, 0.0) if motion.x > 0 \
            else min(motion.x + DECELERATION * delta, 0.0)
    
    if has_x_axis:
        motion.x = clamp(motion.x + x_axis * ACCELERATION * delta, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
    
    # Vertical movement control
    last_able_to_jump = OS.get_ticks_msec() if is_on_floor() else last_able_to_jump
    if OS.get_ticks_msec() - min(last_able_to_jump, last_wanted_to_jump) < JUMP_INPUT_FORGIVENESS \
            and OS.get_ticks_msec() - last_jumped > JUMP_INPUT_FORGIVENESS:
        motion.y = -JUMP_SPEED
        is_jumping = true
        last_jumped = OS.get_ticks_msec()
    
    motion = move_and_slide(motion, Vector2.UP)
    if self.is_on_floor() and self.position.y < WIN_Y:
        self.emit_signal("reached_win_area")

func handle_jump_control(input_event: InputEvent) -> void:
    if input_event.is_action_pressed(InputManager.jump_action):
        self.last_wanted_to_jump = OS.get_ticks_msec()
    elif input_event.is_action_released(InputManager.jump_action):
        stop_jumping()

func stop_jumping() -> void:
    if motion.y < 0.0 and is_jumping:
        motion.y *= JUMP_STOP_SPEED_RETENTION
        is_jumping = false
    elif not is_jumping:
        last_wanted_to_jump = -JUMP_INPUT_FORGIVENESS

static func get_window_height() -> float:
    return ProjectSettings.get_setting("display/window/size/height")
