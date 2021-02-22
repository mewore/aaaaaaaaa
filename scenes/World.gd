extends Node2D

signal active_timer_changed(new_active_timer)

var LOG: Log = LogManager.get_log(self)

onready var LEVEL_OVER_MENU := $LevelOverMenuLayer/WorldPauseMenu as CanvasItem
onready var LEVEL_OVER_OPTION_CONTAINER := $LevelOverMenuLayer/WorldPauseMenu/PauseOptionContainer as OptionContanier
onready var FADE_OVERLAY := $FadeOverlay as FadeOverlay

var paused: bool = false setget set_paused

enum PauseScreen { MAIN, SAVE }
var pause_screen: int = PauseScreen.MAIN setget set_pause_screen

const MANUAL_PAUSING_ENABLED = false

var input_rng: RandomNumberGenerator = RandomNumberGenerator.new()

export(int) var SCRAMBLE_TIME_DECREASE_PER_LEVEL := 2
onready var INPUT_SCRAMBLE_TIMER: Timer = $GameWrapper/InputScrambleTimer
var active_timer: Timer setget set_active_timer

export(int) var BASE_LEVEL_HEIGHT := 1
export(int) var HEIGHT_PER_LEVEL: int = 2
onready var MAP := $GameWrapper/TileMap as Map
onready var PLAYER := $GameWrapper/Player as Player

const RESTART_LEVEL_OPTION := "Restart level"
const NEXT_LEVEL_OPTION := "Next level"
const MAIN_MENU_OPTION := "Main menu"

func set_active_timer(new_active_timer: Timer) -> void:
    active_timer = new_active_timer
    emit_signal("active_timer_changed", active_timer)

func _ready() -> void:
    input_rng.seed = self.name.hash() + Global.current_level
    InputManager.unscramble_inputs()
    if Global.current_level > Global.FIRST_LEVEL:
        InputManager.scramble_inputs(input_rng)
    self.active_timer = INPUT_SCRAMBLE_TIMER
    var pause_overlay_polygon := $LevelOverMenuLayer/WorldPauseMenu/Overlay as Polygon2D
    var alpha: float = pause_overlay_polygon.color.a # a
    pause_overlay_polygon.color = ProjectSettings.get("rendering/environment/default_clear_color")
    pause_overlay_polygon.color.a = alpha
    
    INPUT_SCRAMBLE_TIMER.wait_time -= SCRAMBLE_TIME_DECREASE_PER_LEVEL * Global.current_level
    
    var map_height := BASE_LEVEL_HEIGHT + Global.current_level * HEIGHT_PER_LEVEL
    MAP.initialize_with_height(map_height)
    var cell_height := MAP.cell_size.y
    PLAYER.position.y = cell_height * 0.5 + (map_height - 1) * cell_height
    PLAYER.camera_bottom_limit = (map_height + 1) * cell_height

func _on_InputScrambleTimer_timeout() -> void:
    InputManager.scramble_inputs(input_rng)
    $GameWrapper/AnimationPlayer.play("inputs_changed")

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
    LEVEL_OVER_OPTION_CONTAINER.active_item_index = 0
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
        RESTART_LEVEL_OPTION:
            FADE_OVERLAY.fade_out()
            yield(FADE_OVERLAY, "faded_out")
            self.paused = false
            LOG.check_error_code(get_tree().reload_current_scene(), "Reloading the world")
        NEXT_LEVEL_OPTION:
            FADE_OVERLAY.fade_out()
            yield(FADE_OVERLAY, "faded_out")
            self.paused = false
            LOG.check_error_code(get_tree().reload_current_scene(), "Reloading the world")
        MAIN_MENU_OPTION:
            FADE_OVERLAY.fade_out()
            yield(FADE_OVERLAY, "faded_out")
            self.paused = false
            LOG.check_error_code(get_tree().change_scene("res://scenes/MainMenu.tscn"),
                "Switching to the Main Menu scene")
        _:
            assert(false, "Don't know how to handle option: '%s'" % option)

func _on_Player_won() -> void:
    LEVEL_OVER_OPTION_CONTAINER.title = "You win!"
    LEVEL_OVER_OPTION_CONTAINER.options = PoolStringArray([NEXT_LEVEL_OPTION, MAIN_MENU_OPTION])
    Global.current_level += 1
    Global.save_game()
    self.paused = true

func _on_Player_reached_win_area() -> void:
    INPUT_SCRAMBLE_TIMER.paused = true

func _on_Player_dead() -> void:
    LEVEL_OVER_OPTION_CONTAINER.title = "Oof! You died..."
    LEVEL_OVER_OPTION_CONTAINER.options = PoolStringArray([RESTART_LEVEL_OPTION, MAIN_MENU_OPTION])
    self.paused = true

func _on_FadeOverlay_started_fading_out() -> void:
    LEVEL_OVER_OPTION_CONTAINER.enabled = false
