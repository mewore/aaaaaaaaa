extends Node

var LOG: Log = LogManager.get_log(self)

const ACTION_COUNT = 5

var action_symbols = ["X", "[ ]", "P", "8", "B"]
var actions = ["action1", "action2", "action3", "action4", "action5"]
var input_mapping: PoolIntArray = PoolIntArray([0, 1, 2, 3, 4])

var move_left_action = actions[0]
var move_right_action = actions[1]
var jump_action = actions[2]

func scramble_inputs(rng: RandomNumberGenerator) -> void:
    for i in range(1, ACTION_COUNT):
        var index := rng.randi_range(0, i)
        if index != i:
            var tmp := input_mapping[i]
            input_mapping[i] = input_mapping[index]
            input_mapping[index] = tmp
    
    move_left_action = actions[input_mapping[0]]
    move_right_action = actions[input_mapping[1]]
    jump_action = actions[input_mapping[2]]
    LOG.info("Inputs scrambled. New inputs: %s, %s, %s" % [action_symbols[input_mapping[0]],
        action_symbols[input_mapping[1]], action_symbols[input_mapping[2]]])
