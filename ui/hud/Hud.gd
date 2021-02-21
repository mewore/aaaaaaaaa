extends VBoxContainer

var LOG: Log = LogManager.get_log(self)

const INPUT_ICON_FRAME_OFFSET := 8

onready var MOVE_LEFT_INPUT_ICON := $InputWrapper/InputControl/InputPreview/MoveLeft/Input as Sprite
onready var MOVE_RIGHT_INPUT_ICON := $InputWrapper/InputControl/InputPreview/MoveRight/Input as Sprite
onready var JUMP_INPUT_ICON := $InputWrapper/InputControl/InputPreview/Jump/Input as Sprite

onready var TIME_LABEL := $ControlScrambleTimer as TimeLabel
export(Color) var TIME_WARNING_COLOUR: Color
onready var NORMAL_TIME_COLOUR = TIME_LABEL.self_modulate

onready var HP_BAR := $HpBarWrapper/HpBarControl/HpBar as HpBar

onready var DAMAGE_TAKEN_LABEL := $DamageTaken as Label
export(int) var DAMAGE_TAKEN_SYMBOLS_PER_LINE := 10


var active_timer: Timer

export(NodePath) var PLAYER_NODE: NodePath
onready var PLAYER := get_node_or_null(PLAYER_NODE) as Player

func _ready() -> void:
    refresh_input_icons()
    LOG.check_error_code(InputManager.connect("inputs_changed", self, "_on_inputs_changed"),
        "Connecting the InputManager 'inputs_changed' signal")

func _process(_delta: float) -> void:
    if PLAYER:
        HP_BAR.set_hp_ratio(PLAYER.hp / Player.MAX_HP)

func _on_inputs_changed() -> void:
    self.refresh_input_icons()

func refresh_input_icons() -> void:
    MOVE_LEFT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_left_action_index
    MOVE_RIGHT_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.move_right_action_index
    JUMP_INPUT_ICON.frame = INPUT_ICON_FRAME_OFFSET + InputManager.jump_action_index
    $AnimationPlayer.play("inputs_changed")

func _on_World_active_timer_changed(new_active_timer: Timer) -> void:
    TIME_LABEL.timer = new_active_timer

func _on_Player_hit() -> void:
    if DAMAGE_TAKEN_LABEL.text.count("x") % DAMAGE_TAKEN_SYMBOLS_PER_LINE == 0:
        DAMAGE_TAKEN_LABEL.text += '\n';
    DAMAGE_TAKEN_LABEL.text += 'x'

func _on_ControlScrambleTimer_updated(total_seconds_left: int) -> void:
    print("a ", total_seconds_left)
    TIME_LABEL.self_modulate = TIME_WARNING_COLOUR \
        if TIME_WARNING_COLOUR and (total_seconds_left < 10 and total_seconds_left % 2 == 1) \
        else NORMAL_TIME_COLOUR
