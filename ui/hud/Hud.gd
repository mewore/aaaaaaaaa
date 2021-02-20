extends VBoxContainer

var LOG: Log = LogManager.get_log(self)

const INPUT_ICON_FRAME_OFFSET := 8

onready var MOVE_LEFT_INPUT_ICON := $InputWrapper/InputControl/InputPreview/MoveLeft/Input as Sprite
onready var MOVE_RIGHT_INPUT_ICON := $InputWrapper/InputControl/InputPreview/MoveRight/Input as Sprite
onready var JUMP_INPUT_ICON := $InputWrapper/InputControl/InputPreview/Jump/Input as Sprite

onready var TIME_LABEL := $ControlScrambleTimer as Label

onready var HP_BAR := $HpBarWrapper/HpBarControl/HpBar as HpBar

var active_timer: Timer

export(NodePath) var PLAYER_NODE: NodePath
onready var PLAYER := get_node_or_null(PLAYER_NODE) as Player

func _ready() -> void:
    refresh_input_icons()
    LOG.check_error_code(InputManager.connect("inputs_scrambled", self, "_on_inputs_scrambled"),
        "Connecting the InputManager 'inputs_scrambled' signal")

func _process(_delta: float) -> void:
    if active_timer:
        var time_left_seconds_total := int(floor(active_timer.time_left))
        var minutes_left := int(float(time_left_seconds_total) / 60)
        var seconds_left := time_left_seconds_total % 60
        TIME_LABEL.text = "%d%d:%d%d" % [int(float(minutes_left) / 10), minutes_left % 10,
            int(float(seconds_left) / 10), seconds_left % 10]
    if PLAYER:
        HP_BAR.set_hp_ratio(PLAYER.hp / Player.MAX_HP)

func _on_inputs_scrambled() -> void:
    self.refresh_input_icons()

func refresh_input_icons() -> void:
    MOVE_LEFT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_left_action_index
    MOVE_RIGHT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_right_action_index
    JUMP_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.jump_action_index

func _on_World_active_timer_changed(new_active_timer: Timer) -> void:
    self.active_timer = new_active_timer
