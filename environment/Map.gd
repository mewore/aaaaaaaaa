class_name Map

extends TileMap

export(int) var LEFTMOST_FREE_CELL: int
export(int) var RIGHTMOST_FREE_CELL: int
export(int) var LEFT_PADDING: int = 3
export(int) var RIGHT_PADDING: int = 10
export(int) var BOTTOM_PADDING: int = 3
export(int) var TOP_PADDING: int = 10

var bottom_y: float

func initialize_with_height(new_height: int) -> void:
    var ground_tile: int = self.tile_set.find_tile_by_name("ground")
    self.clear()
    
    # Roof
    var top_y := -TOP_PADDING - 1

    # Walls
    for _y in range(top_y + 1, new_height):
        var y := _y as int
        for _x in range(LEFTMOST_FREE_CELL - LEFT_PADDING, LEFTMOST_FREE_CELL):
            self.set_cell(_x as int, y, ground_tile)
        for _x in range(RIGHTMOST_FREE_CELL + 1, RIGHTMOST_FREE_CELL + RIGHT_PADDING + 1):
            self.set_cell(_x as int, y, ground_tile)
    
    # Floor
    for _y in range(new_height, new_height + BOTTOM_PADDING):
        add_slab(_y as int, ground_tile)
    
    self.update_bitmask_region()

func add_slab(y: int, tile: int) -> void:
    for _x in range(LEFTMOST_FREE_CELL - LEFT_PADDING, RIGHTMOST_FREE_CELL + RIGHT_PADDING + 1):
        self.set_cell(_x as int, y, tile)
