extends Node2D

signal active_timer_changed(new_active_timer)

var LOG: Log = LogManager.get_log(self)

onready var LEVEL_OVER_MENU := $LevelOverMenuLayer/WorldPauseMenu as CanvasItem
onready var LEVEL_OVER_OPTION_CONTAINER := $LevelOverMenuLayer/WorldPauseMenu/PauseOptionContainer as OptionContanier

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
    input_rng.seed = self.name.hash()
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
    LEVEL_OVER_MENU.visible = paused
    get_tree().paused = paused
    LEVEL_OVER_OPTION_CONTAINER.active_option_index = 0
    self.pause_screen = PauseScreen.MAIN

func set_pause_screen(new_pause_screen: int) -> void:
    pause_screen = new_pause_screen
    var index = 0
    var nodes: Array = LEVEL_OVER_MENU.get_children()
    for _node in nodes:
        if _node is OptionContanier:
            var node: CanvasItem = _node
            node.visible = new_pause_screen == index
            index += 1

func _on_PauseOptionContainer_option_selected(_option_index: int, option: String) -> void:
    match option:
        "Restart":
            self.paused = false
            LOG.check_error_code(get_tree().reload_current_scene(), "Reloading the world")
        "Main menu":
            self.paused = false
            LOG.check_error_code(get_tree().change_scene("res://scenes/MainMenu.tscn"),
                "Switching to the Main Menu scene")
        _:
            assert(false, "Don't know how to handle option: '%s'" % option)

func _on_Player_won() -> void:
    LEVEL_OVER_OPTION_CONTAINER.title = "You win!"
    self.paused = true

func _on_Player_reached_win_area() -> void:
    ($GameWrapper/FallingBlockContainer as FallingBlockContainer).topmost_row = null
    INPUT_SCRAMBLE_TIMER.paused = true
    for _falling_block in get_tree().get_nodes_in_group("falling_block"):
        var falling_block := _falling_block as FallingBlock
        falling_block.megumin()

func _on_Player_dead() -> void:
    LEVEL_OVER_OPTION_CONTAINER.title = "Oof! You died..."
    self.paused = true
