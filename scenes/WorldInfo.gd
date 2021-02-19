class_name WorldInfo

extends Node

export(int) var CELL_WIDTH: int = 16
export(int) var CELL_HEIGHT: int = 16

var map: Dictionary = {}

func register_cell(cell_x: int, cell_y: int, cell_value) -> void:
    if not map.has(cell_y):
        map[cell_y] = {}
    var row: Dictionary = map.get(cell_y)
    row[cell_x] = cell_value

func is_cell_occupied(cell_x: int, cell_y: int) -> bool:
    return map.has(cell_y) and map[cell_y].has(cell_x)
