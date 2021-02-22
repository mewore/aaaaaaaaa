extends VBoxContainer

var LOG := LogManager.get_log(self)

onready var OPTION_CONTAINER := $OptionWrapper/OptionContainer as OptionContanier

var GAME_TITLE := ProjectSettings.get("application/config/name") as String

const NEW_GAME_OPTION := "Start new game"
const CONTINUE_OPTION := "Continue"
const SFX_VOLUME_SETTING_LABEL := "SFX"
var SFX_VOLUME_SLIDER := SliderMenuItem.new("SFX")
const EXIT_OPTION := "Exit"

const NO_SAVED_GAMES_PSEUDO_OPTION := "No saved games"

var MAIN_MENU_ITEM_SET := MenuItemSet.new("Main menu")
var active_menu: MenuItemSet setget set_active_menu

onready var FADE_OVERLAY := $FadeOverlay as FadeOverlay

func _ready() -> void:
    var main_menu_items := [BasicMenuItem.new(NEW_GAME_OPTION), SFX_VOLUME_SLIDER]
    if Global.save_file_exists(Global.DEFAULT_SAVE_FILE):
        main_menu_items.push_front(BasicMenuItem.new(CONTINUE_OPTION))
    if not OS.has_feature("web"):
        main_menu_items.append(BasicMenuItem.new(EXIT_OPTION))
    MAIN_MENU_ITEM_SET.items = main_menu_items
    
    LOG.check_error_code(SFX_VOLUME_SLIDER.connect("changed", self, "_on_sfx_slider_changed"),
        "Connecting the 'changed' signal of the SFX volume slider")
    self.active_menu = MAIN_MENU_ITEM_SET
    
    SFX_VOLUME_SLIDER.value = Global.settings.get_sfx_volume_ratio()
    OPTION_CONTAINER.update_list_text()

func _on_sfx_slider_changed() -> void:
    Global.settings.set_sfx_volume_ratio(SFX_VOLUME_SLIDER.value)
    Global.save_settings()

func set_active_menu(new_active_menu: MenuItemSet) -> void:
    active_menu = new_active_menu
    OPTION_CONTAINER.title = active_menu.title
    OPTION_CONTAINER.menu_items = active_menu.items

func _on_OptionContainer_option_selected(_option_index: int, option: String) -> void:
    match active_menu:
        MAIN_MENU_ITEM_SET:
            match option:
                CONTINUE_OPTION:
                    FADE_OVERLAY.fade_out()
                    yield(FADE_OVERLAY, "faded_out")
                    self.start_game(Global.DEFAULT_SAVE_FILE)
                NEW_GAME_OPTION:
                    FADE_OVERLAY.fade_out()
                    yield(FADE_OVERLAY, "faded_out")
                    self.start_game()
                EXIT_OPTION:
                    FADE_OVERLAY.fade_out()
                    yield(FADE_OVERLAY, "faded_out")
                    get_tree().quit()
                _:
                    assert(false, "Don't know how to handle option: '%s'" % option)
        _:
            assert(false, "Don't know how to handle menu '%s'" % active_menu.title)

func start_game(saved_game: String = "") -> void:
    if saved_game.empty():
        Global.new_game()
    else:
        Global.load_game(saved_game)
    LOG.check_error_code(get_tree().change_scene("res://scenes/World.tscn"),
        "Switching to the World scene")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and active_menu != MAIN_MENU_ITEM_SET:
        self.active_menu = MAIN_MENU_ITEM_SET
        self.accept_event()

func _on_FadeOverlay_started_fading_out() -> void:
    OPTION_CONTAINER.enabled = false

class MenuItemSet:
    var title: String
    var items: Array
    
    func _init(initial_title: String, initial_items: Array = []) -> void:
        title = initial_title
        items = initial_items
