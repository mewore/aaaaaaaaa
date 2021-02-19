class_name StateMachine

extends Node

signal state_name_changed(new_state_name)

var LOG: Log = LogManager.get_log(self)

export(NodePath) var OWNER = ".."

var current_state_name: String setget set_current_state_name
var current_state: State

onready var STATE_COLLECTION: StateCollection = StateCollection.new(self)

var history: Array = []

func _ready() -> void:
    self.owner = get_node(OWNER)
    self.current_state_name = ""
    
    if not STATE_COLLECTION.has_states():
        return
    
    for _state in STATE_COLLECTION.valid_states:
        var state: State = _state
        LOG.check_error_code(
            state.connect("next_state_requested", self, "_on_next_state_requested"),
            "Connecting to the 'next_state_requested' signal of state '%s'" % state.name)
        state.set_owner(self.owner)
    
    current_state = STATE_COLLECTION.get_first_state()
    current_state_name = current_state.name
    
    LOG.info("The available states are: [%s]" %
        [PoolStringArray(STATE_COLLECTION.state_map.keys()).join(", ")])
    for _child in STATE_COLLECTION.valid_states:
        var child: State = _child
        LOG.debug("Initializing state: " + child.name)
        child.initialize()
    history.append(current_state_name)
    _enter_state()

func has_states() -> bool:
    return STATE_COLLECTION.has_states()

func get_first_state() -> State:
    return STATE_COLLECTION.get_first_state()

func change_to(new_state_name: String) -> void:
    if new_state_name == State.PREVIOUS_STATE:
        self.back()
    elif new_state_name == State.DISAPPEAR_STATE:
        if owner.has_method("disappear"):
            owner.disappear()
        else:
            owner.queue_free()
    else:
        set_state(new_state_name)
        history.append(new_state_name)

func back() -> void:
    if history.size() >= 2:
        var last_history_state: String = history.pop_back()
        if last_history_state != current_state_name:
            LOG.error("last_history_state (%s) is different from state_name (%s)" %
                [last_history_state, current_state_name])
        var previous_state: String = history.back()
        LOG.debug("Going back from state '%s' to '%s'" % [current_state_name, previous_state])
        set_state(previous_state)
    else:
        LOG.error("Cannot go to a previous state! The history is empty!")

func set_state(new_state_name: String) -> void:
    var new_state: State = STATE_COLLECTION.state_map[new_state_name]
    
    LOG.debug("Changing the state to '%s'" % [new_state_name])
    if !STATE_COLLECTION.state_map.has(new_state_name):
        LOG.error("State '%s' does not exist! The available states are: %s" %
            [new_state_name, PoolStringArray(STATE_COLLECTION.state_map.keys()).join(", ")])
        return
    _exit_state()
    self.current_state_name = new_state_name
    self.current_state = new_state
    _enter_state()

func set_current_state_name(new_state_name: String) -> void:
    current_state_name = new_state_name
    emit_signal("state_name_changed", new_state_name)

func get_current_state_name() -> String:
    return current_state_name if current_state_name \
        else STATE_COLLECTION.get_first_state().name

func _on_next_state_requested(requester: Node, next_state: String) -> void:
    if requester == current_state:
        self.change_to(next_state)
    else:
        LOG.error(("State '%s' has requested a change to state '%s' but it isn't active at the moment " +
            "(The active state is '%s')") % [requester.name, next_state, current_state_name])

func _enter_state() -> void:
    if current_state:
        LOG.trace("Entering state: " + current_state.name)
        current_state.active = true
        current_state.enter()
        current_state.enter_done()

func _exit_state() -> void:
    if current_state:
        LOG.trace("Exiting state: " + current_state.name)
        current_state.exit()
        current_state.active = false
        current_state.exit_done()

func _process(delta: float) -> void:
    if current_state:
        if self.current_state.next_state:
            self.change_to(self.current_state.next_state)
    
        current_state.process(delta)

func _physics_process(delta: float):
    if current_state:
        if self.current_state.next_state:
            self.change_to(self.current_state.next_state)
    
        current_state.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.unhandled_input(event)

func _unhandled_key_input(event: InputEventKey) -> void:
    if current_state:
        current_state.unhandled_key_input(event)
