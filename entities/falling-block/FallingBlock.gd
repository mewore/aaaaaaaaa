class_name FallingBlock

extends Node2D

var LOG: Log = LogManager.get_log(self)

# The minimum distance (Manhattan - separately on the X and Y axes) from the player, which is required for this block to
# turn into a map tile
const REQUIRED_PLAYER_DISTANCE_RATIO: float = 0.5

onready var SPRITE := $Sprite as Sprite

var player: Node2D
var map_to_merge_into: TileMap

var upper_block: FallingBlock setget set_upper_block
var lower_block: FallingBlock setget set_lower_block

var settings: FallingBlockSettings

func set_upper_block(new_upper_block: FallingBlock) -> void:
    upper_block = new_upper_block
    if upper_block:
        LOG.check_error_code(upper_block.connect("tree_exited", self, "_on_upper_block_gone"),
            "Connecting the upper block's 'tree_exited' signal")
    refresh_sprite()

func set_lower_block(new_lower_block: FallingBlock) -> void:
    lower_block = new_lower_block
    if lower_block:
        LOG.check_error_code(lower_block.connect("tree_exited", self, "_on_lower_block_gone"),
            "Connecting the lower block's 'tree_exited' signal")
    refresh_sprite()

func _ready() -> void:
    self.refresh_sprite()

func _physics_process(delta : float) -> void:
    if not map_to_merge_into:
        self.position.y += (settings.get_fall_speed() if settings else FallingBlockSettings.DEFAULT_FALL_SPEED) * delta

func _process(_delta: float) -> void:
    if map_to_merge_into:
        if player:
            var cell_size: Vector2 = map_to_merge_into.cell_size
            if abs(self.position.x - player.position.x) > cell_size.x * REQUIRED_PLAYER_DISTANCE_RATIO \
                    or abs(self.position.y - player.position.y) > cell_size.y * REQUIRED_PLAYER_DISTANCE_RATIO:
                merge_into_map()
        else:
            merge_into_map()

func refresh_sprite() -> void:
    if SPRITE:
        # Dumb-looking formula. Whatever.
        SPRITE.frame = (1 if upper_block else 0) | (2 if lower_block else 0)

func merge_into_map() -> void:
    var cell_pos: Vector2 = map_to_merge_into.world_to_map(self.to_global(Vector2.ZERO))
    map_to_merge_into.set_cell(int(cell_pos.x), int(cell_pos.y), map_to_merge_into.tile_set.find_tile_by_name("ground"))
    map_to_merge_into.update_bitmask_area(cell_pos)
    queue_free()

func _on_GroundCollisionArea_body_entered(body: Node) -> void:
    if body is TileMap:
        self.map_to_merge_into = body

func _on_upper_block_gone() -> void:
    self.upper_block = null

func _on_lower_block_gone() -> void:
    self.lower_block = null

func _on_AttackBox_area_entered(area: Area2D) -> void:
    var entity := area.owner
    if entity.has_method("take_damage"):
        entity.take_damage()
    self.megumin()

func megumin() -> void:
    queue_free()
