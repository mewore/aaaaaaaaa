class_name FallingBlockContainer

extends Node2D

export(float, 0.0, 1.0) var BLOCK_DENSITY: float = 0.05

export(NodePath) var PLAYER_NODE: String
onready var PLAYER := get_node_or_null(PLAYER_NODE) as Node2D

export(NodePath) var MAP_NODE: String
onready var MAP := get_node(MAP_NODE) as TileMap
onready var CELL_SIZE := MAP.cell_size

export(PackedScene) var FALLING_BLOCK_SCENE: PackedScene

onready var WINDOW_HEIGHT: float = ProjectSettings.get_setting("display/window/size/height")
var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

onready var MIN_SPAWN_X := ($LeftmostSpawn as Position2D).position.x
onready var MAX_SPAWN_X := ($RightmostSpawn as Position2D).position.x
onready var BLOCKS_PER_ROW := int((MAX_SPAWN_X - MIN_SPAWN_X) / CELL_SIZE.x) + 1

onready var ANIMATION_PLAYER := $AnimationPlayer
onready var SETTINGS := $Settings as FallingBlockSettings

var topmost_row: BlockRow

func _ready() -> void:
    RNG.seed = self.name.hash()
    topmost_row = create_row_at_y(get_player_sight_line_y())
    topmost_row.add_all_blocks(self)

func _process(delta: float) -> void:
    if not topmost_row:
        return
    var target_spawn_y := get_player_sight_line_y()
    topmost_row.y += SETTINGS.get_fall_speed() * delta
    while topmost_row.y >= target_spawn_y:
        var new_row := create_row_at_y(topmost_row.y - CELL_SIZE.y)
        topmost_row.set_upper_row(new_row)
        topmost_row = new_row
        topmost_row.add_all_blocks(self)

func create_row_at_y(y: float) -> BlockRow:
    return BlockRow.new(Vector2(MIN_SPAWN_X, y), BLOCKS_PER_ROW, FALLING_BLOCK_SCENE, CELL_SIZE.x, BLOCK_DENSITY, RNG,
        PLAYER, SETTINGS)

func get_player_sight_line_y() -> float:
    return PLAYER.position.y - WINDOW_HEIGHT - CELL_SIZE.y

func _on_Player_reached_win_area() -> void:
    self.topmost_row = null
    for _falling_block in get_tree().get_nodes_in_group("falling_block"):
        var falling_block := _falling_block as FallingBlock
        falling_block.megumin()

func freeze_blocks() -> void:
    ANIMATION_PLAYER.play("freeze_blocks")

func unfreeze_blocks() -> void:
    ANIMATION_PLAYER.play("unfreeze_blocks")

class BlockRow:
    
    # The position of the leftmost block
    var y: float
    
    var blocks: Array = []
    
    func _init(
            pos: Vector2,
            block_count: int,
            block_scene: PackedScene,
            block_width: float,
            block_density: float,
            rng: RandomNumberGenerator,
            player: Node2D,
            settings: FallingBlockSettings) -> void:
        
        self.y = pos.y
        var x: float = pos.x
        for _i in range(block_count):
            if rng.randf() < block_density:
                var block := block_scene.instance() as FallingBlock
                block.position = Vector2(x, pos.y)
                block.player = player
                block.settings = settings
                blocks.append(block)
            else:
                blocks.append(null)
            x += block_width

    func has_block(index: int) -> bool:
        return self.blocks[index] != null
    
    func get_block(index: int) -> FallingBlock:
        return self.blocks[index] as FallingBlock

    func add_all_blocks(target: Node) -> void:
        for block in self.blocks:
            if block:
                target.add_child(block)

    func set_upper_row(upper_row: BlockRow) -> void:
        for _i in range(blocks.size()):
            var i := _i as int
            if has_block(i) and upper_row.has_block(i):
                var lower := get_block(i)
                var upper := upper_row.get_block(i)
                lower.upper_block = upper
                upper.lower_block = lower
