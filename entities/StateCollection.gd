class_name StateCollection

var valid_states: Array = []
var state_map: Dictionary = {}

func _init(state_machine_node: Node) -> void:
    self.valid_states = []
    self.state_map = {}
    
    var children: Array = state_machine_node.get_children()
    
    for _child in children:
        var child_node: Node = _child
        if not child_node is State:
            continue

        var state: State = _child
        self.valid_states.append(state)
        self.state_map[state.name] = state

func has_states() -> bool:
    return not valid_states.empty()

func get_first_state() -> State:
    return valid_states[0]
