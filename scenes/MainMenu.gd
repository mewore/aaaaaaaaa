extends VBoxContainer

var LOG: Log = LogManager.get_log(self)

onready var OPTION_CONTAINER: OptionContanier = $OptionWrapper/OptionContainer

var GAME_TITLE = ProjectSettings.get("application/config/name")

const NEW_GAME_OPTION = "Start new game"
const EXIT_OPTION = "Exit"

const NO_SAVED_GAMES_PSEUDO_OPTION = "No saved games"

var MAIN_OPTION_SET := OptionSet.new("Main menu")
var active_options: OptionSet setget set_active_options

func _ready() -> void:
    var main_options: PoolStringArray = PoolStringArray([NEW_GAME_OPTION])
    if not OS.has_feature("web"):
        main_options.append(EXIT_OPTION)
    MAIN_OPTION_SET.options = main_options

    self.active_options = MAIN_OPTION_SET

func set_active_options(new_active_options: OptionSet) -> void:
    active_options = new_active_options
    OPTION_CONTAINER.title = active_options.title
    OPTION_CONTAINER.options = active_options.options

func _on_OptionContainer_option_selected(_option_index: int, option: String) -> void:
    match active_options:
        MAIN_OPTION_SET:
            match option:
                NEW_GAME_OPTION:
                    self.start_game()
                EXIT_OPTION:
                    get_tree().quit()
                _:
                    assert(false, "Don't know how to handle option: '%s'" % option)
        _:
            assert(false, "Don't know how to handle option set '%s'" % active_options.title)

func start_game(saved_game: String = "") -> void:
    if saved_game.empty():
        Global.new_game()
    else:
        Global.load_game(saved_game)
    LOG.check_error_code(get_tree().change_scene("res://scenes/World.tscn"),
        "Switching to the World scene")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and active_options != MAIN_OPTION_SET:
        self.active_options = MAIN_OPTION_SET
        self.accept_event()

class OptionSet:
    var title: String
    var options: PoolStringArray
    
    func _init(initial_title: String, initial_options: PoolStringArray = PoolStringArray([])) -> void:
        title = initial_title
        options = initial_options
