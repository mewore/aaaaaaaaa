tool
extends Label

const NO_STATES: String = "No states"

const GOOD_COLOUR: Color = Color.palegreen
const BAD_COLOUR: Color = Color.palevioletred

const DEFER_TIME: int = 100
var refresh_at: int = 0

export(NodePath) var STATE_MACHINE: NodePath = "./../StateMachine" setget set_state_machine_path

func _ready() -> void:
    if Engine.editor_hint:
        var _error_code: int
        _error_code = get_tree().connect("tree_changed", self, "_on_tree_changed")
        _error_code = get_tree().connect("node_configuration_warning_changed", self, "_on_node_changed")
        _error_code = self.connect("visibility_changed", self, "_on_visibility_changed")
        refresh_state()
        return
    
    if not visible:
        queue_free()
        return
    
    if not validate_state_machine():
        return
    
    var state_machine: StateMachine = get_node(STATE_MACHINE)
    yield(state_machine, "ready")
    var error_code: int = state_machine.connect("state_name_changed", self, "_on_StateMachine_state_name_changed")
    LogManager.get_log(self).check_error_code(error_code, "Connecting to 'state_name_changed'")
    if state_machine.has_states():
        set_state_text(state_machine.get_first_state().name, GOOD_COLOUR)
    else:
        set_state_text(NO_STATES, BAD_COLOUR)

func _process(_delta: float) -> void:
    if Engine.editor_hint and refresh_at != 0:
        var now: int = OS.get_ticks_msec()
        if now >= refresh_at:
            refresh_at = 0
            refresh_state()

func validate_state_machine() -> bool:
    if not has_node(STATE_MACHINE):
        self.set_state_text("No state machine", BAD_COLOUR)
        return false

    if not get_node(STATE_MACHINE) is StateMachine:
        self.set_state_text("Invalid state machine type", BAD_COLOUR)
        return false

    return true

func set_state_machine_path(new_state_machine_path: NodePath) -> void:
    STATE_MACHINE = new_state_machine_path
    refresh_state()

func _on_node_changed(_node: Node) -> void:
    if visible:
        schedule_refresh()

func _on_tree_changed() -> void:
    if visible:
        schedule_refresh()

func _on_visibility_changed() -> void:
    schedule_refresh()

func schedule_refresh() -> void:
    var now: int = OS.get_ticks_msec()
    refresh_at = now + DEFER_TIME

func refresh_state() -> void:
    if not visible:
        return
    
    if validate_state_machine():
        var state_collection: StateCollection = StateCollection.new(get_node(STATE_MACHINE))
        if state_collection.has_states():
            self.set_state_text(state_collection.get_first_state().name, GOOD_COLOUR)
        else:
            self.set_state_text(NO_STATES, BAD_COLOUR)

func _on_StateMachine_state_name_changed(new_state_name: String) -> void:
    set_state_text(new_state_name, GOOD_COLOUR)

func set_state_text(state_text: String, colour: Color) -> void:
    self.text = "[%s]" % state_text
    self.self_modulate = colour
