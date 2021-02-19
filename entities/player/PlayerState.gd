class_name PlayerState

extends State

const MOVING: String = "Moving"
const DYING: String = "Dying"
const DEAD: String = "Dead"
const WINNING: String = "Winning"
var player: Player

func set_owner(owner: Node) -> void:
    .set_owner(owner)
    assert(owner is Player)
    self.player = owner
