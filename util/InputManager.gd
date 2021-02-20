extends Node

signal inputs_scrambled()

var LOG: Log = LogManager.get_log(self)

const ACTION_COUNT = 5

var action_symbols = ["X", "[ ]", "P", "8", "B"]
var actions = ["action1", "action2", "action3", "action4", "action5"]
var input_mapping: PoolIntArray = PoolIntArray([0, 1, 2, 3, 4])

var move_left_action_index := 0 setget set_move_left_action_index
var move_right_action_index := 1 setget set_move_right_action_index
var jump_action_index := 2 setget set_jump_action_index

var move_left_action: String
var move_right_action: String
var jump_action: String

func set_move_left_action_index(new_move_left_action_index: int) -> void:
    move_left_action_index = new_move_left_action_index
    move_left_action = actions[move_left_action_index]

func set_move_right_action_index(new_move_right_action_index: int) -> void:
    move_right_action_index = new_move_right_action_index
    move_right_action = actions[move_right_action_index]

func set_jump_action_index(new_jump_action_index: int) -> void:
    jump_action_index = new_jump_action_index
    jump_action = actions[jump_action_index]

func scramble_inputs(rng: RandomNumberGenerator) -> void:
    for i in range(1, ACTION_COUNT):
        var index := rng.randi_range(0, i)
        if index != i:
            var tmp := input_mapping[i]
            input_mapping[i] = input_mapping[index]
            input_mapping[index] = tmp
    
    self.move_left_action_index = input_mapping[0]
    self.move_right_action_index = input_mapping[1]
    self.jump_action_index = input_mapping[2]
    LOG.info("Inputs scrambled. New inputs: %s, %s, %s" % [action_symbols[input_mapping[0]],
        action_symbols[input_mapping[1]], action_symbols[input_mapping[2]]])
    emit_signal("inputs_scrambled")
