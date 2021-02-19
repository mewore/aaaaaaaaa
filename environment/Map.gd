extends TileMap

func _ready() -> void:
    var mushroom_tile: int = tile_set.find_tile_by_name("mushroom")
    for _mushroom in get_tree().get_nodes_in_group("mushroom"):
        var mushroom: Node2D = _mushroom
        var cell_pos: Vector2 = self.world_to_map(mushroom.to_global(Vector2.ZERO))
        self.set_cell(int(cell_pos.x), int(cell_pos.y), mushroom_tile)
