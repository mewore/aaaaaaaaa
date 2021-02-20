extends Node2D

signal active_timer_changed(new_active_timer)

var LOG: Log = LogManager.get_log(self)

const NEW_SAVE_OPTION = "(New save)"

onready var PAUSE_MENU: CanvasItem = $PauseMenuLayer/WorldPauseMenu
onready var PAUSE_OPTION_CONTAINER: OptionContanier = $PauseMenuLayer/WorldPauseMenu/PauseOptionContainer
onready var SAVE_OPTION_CONTAINER: OptionContanier = $PauseMenuLayer/WorldPauseMenu/SaveOptionContainer

const DATE_TIME_FORMAT = "{year}-{month}-{day}-{hour}-{minute}-{second}"
const DATE_TIME_PADDING = 2

var paused: bool = false setget set_paused

enum PauseScreen { MAIN, SAVE }
var pause_screen: int = PauseScreen.MAIN setget set_pause_screen

const MANUAL_PAUSING_ENABLED = false

var input_rng: RandomNumberGenerator = RandomNumberGenerator.new()

onready var INPUT_SCRAMBLE_TIMER: Timer = $GameWrapper/InputScrambleTimer
var active_timer: Timer setget set_active_timer

func set_active_timer(new_active_timer: Timer) -> void:
    active_timer = new_active_timer
    emit_signal("active_timer_changed", active_timer)

func _ready() -> void:
    input_rng.seed = "input_rng".hash()
    InputManager.scramble_inputs(input_rng)
    self.active_timer = INPUT_SCRAMBLE_TIMER

func _on_InputScrambleTimer_timeout() -> void:
    InputManager.scramble_inputs(input_rng)

func _input(event: InputEvent) -> void:
    if MANUAL_PAUSING_ENABLED && event.is_action_pressed("ui_cancel"):
        if self.paused and self.pause_screen != PauseScreen.MAIN:
            self.pause_screen = PauseScreen.MAIN
        else:
            self.paused = not self.paused

func set_paused(new_paused: bool) -> void:
    paused = new_paused
    PAUSE_MENU.visible = paused
    get_tree().paused = paused
    PAUSE_OPTION_CONTAINER.active_option_index = 0
    self.pause_screen = PauseScreen.MAIN

func set_pause_screen(new_pause_screen: int) -> void:
    pause_screen = new_pause_screen
    var index = 0
    var nodes: Array = PAUSE_MENU.get_children()
    for _node in nodes:
        if _node is OptionContanier:
            var node: CanvasItem = _node
            node.visible = new_pause_screen == index
            index += 1

func _on_PauseOptionContainer_option_selected(_option_index: int, option: String) -> void:
    match option:
        "Continue":
            self.paused = false
        "Save":
            self.refresh_save_options()
            self.pause_screen = PauseScreen.SAVE
        "Main menu":
            self.paused = false
            LOG.check_error_code(get_tree().change_scene("res://scenes/MainMenu.tscn"),
                "Switching to the Main Menu scene")
        _:
            assert(false, "Don't know how to handle option: '%s'" % option)

func _on_SaveOptionContainer_option_selected(_option_index, option):
    match option:
        NEW_SAVE_OPTION:
            Global.save_game(get_file_name())
            self.refresh_save_options()
        _:
            Global.save_game(get_file_name(), option)
            self.refresh_save_options()

static func get_file_name() -> String:
    return _get_current_time()
    
static func _get_current_time() -> String:
    var date_time: Dictionary = OS.get_datetime()
    _pad_zeroes_in_dictionary(date_time, DATE_TIME_PADDING)
    return DATE_TIME_FORMAT.format(date_time)

static func _pad_zeroes_in_dictionary(dictionary: Dictionary, padding: int) -> void:
    for key in dictionary:
        dictionary[key] = str(dictionary[key]).pad_zeros(padding)

func refresh_save_options() -> void:
    var save_options: PoolStringArray = Global.get_save_files()
    save_options.append(NEW_SAVE_OPTION)
    save_options.invert()
    SAVE_OPTION_CONTAINER.options = save_options
    SAVE_OPTION_CONTAINER.active_option_index = 1
