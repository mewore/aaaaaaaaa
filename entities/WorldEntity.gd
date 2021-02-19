extends Node2D

var LOG: Log = LogManager.get_log(self)

onready var WORLD_INFO: WorldInfo = Global.get_world_info()

var data: Dictionary = {}
var cell_x: int = 0 setget set_cell_x
var cell_y: int = 0 setget set_cell_y

func set_cell_x(new_cell_x: int) -> void:
    cell_x = new_cell_x
    self.position.x = cell_x * WORLD_INFO.CELL_WIDTH

func set_cell_y(new_cell_y: int) -> void:
    cell_y = new_cell_y
    self.position.y = cell_y * WORLD_INFO.CELL_HEIGHT

func _ready() -> void:
    if not is_zero_approx(fmod(self.position.x, WORLD_INFO.CELL_WIDTH)):
        LOG.warn("The X position of entity %s (%f) is not an exact multiple of the cell width (%d)" %
            [self.name, self.position.x, WORLD_INFO.CELL_WIDTH])
    if not is_zero_approx(fmod(self.position.y, WORLD_INFO.CELL_HEIGHT)):
        LOG.warn("The Y position of entity %s (%f) is not an exact multiple of the cell height (%d)" %
            [self.name, self.position.y, WORLD_INFO.CELL_HEIGHT])

    self.cell_x = int(round(self.position.x / WORLD_INFO.CELL_WIDTH))
    self.cell_y = int(round(self.position.y / WORLD_INFO.CELL_WIDTH))

    var id: String = self.name
    if Global.game_data.has(id):
        self.data = Global.game_data[id]
        self.load_data()
    else:
        Global.game_data[id] = self.data

func load_data() -> void:
    if self.data.get("erased", false):
        self.queue_free()
        return
    
    if (self.data.has("cell_x")):
        self.cell_x = self.data["cell_x"]
    if (self.data.has("cell_y")):
        self.cell_y = self.data["cell_y"]

func save_data() -> void:
    pass

func queue_free():
    self.data["erased"] = true
    .queue_free()
