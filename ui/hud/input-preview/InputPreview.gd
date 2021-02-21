class_name InputPreview

extends Node2D

signal inputs_changed()

var LOG: Log = LogManager.get_log(self)

const INPUT_ICON_FRAME_OFFSET := 8
const ACTIVE_OPACITY := 1.0
export(float, 0.0, 1.0) var INACTIVE_ACTION_OPACITY := 0.5

onready var MOVE_LEFT_NODE := $Wrapper/MoveLeft as CanvasItem
onready var MOVE_LEFT_INPUT_ICON := MOVE_LEFT_NODE.get_node("Input") as Sprite

onready var MOVE_RIGHT_NODE := $Wrapper/MoveRight as CanvasItem
onready var MOVE_RIGHT_INPUT_ICON := MOVE_RIGHT_NODE.get_node("Input") as Sprite

onready var JUMP_NODE := $Wrapper/Jump as CanvasItem
onready var JUMP_INPUT_ICON := JUMP_NODE.get_node("Input") as Sprite

func _ready() -> void:
    self.refresh_input_icons()
    LOG.check_error_code(InputManager.connect("inputs_changed", self, "_on_inputs_changed"),
        "Connecting the InputManager 'inputs_changed' signal")

func _on_inputs_changed() -> void:
    self.refresh_input_icons()
    self.emit_signal("inputs_changed")

func refresh_input_icons() -> void:
    MOVE_LEFT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_left_action_index
    MOVE_RIGHT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_right_action_index
    JUMP_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.jump_action_index
    self.refresh_opacity()
    $AnimationPlayer.play("inputs_changed")

func _unhandled_input(_event: InputEvent) -> void:
    self.refresh_opacity()

func refresh_opacity() -> void:
    MOVE_LEFT_NODE.modulate.a = self.get_action_opacity(InputManager.move_left_action)
    MOVE_RIGHT_NODE.modulate.a = self.get_action_opacity(InputManager.move_right_action)
    JUMP_NODE.modulate.a = self.get_action_opacity(InputManager.jump_action)

func get_action_opacity(action: String) -> float:
    return ACTIVE_OPACITY if Input.is_action_pressed(action) else INACTIVE_ACTION_OPACITY
