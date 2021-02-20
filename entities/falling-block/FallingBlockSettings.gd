class_name FallingBlockSettings

extends Node

const FALL_DOWN_SPEED: float = 50.0

# For pausing
export(float, 0.0, 1.0) var speed_multiplier: float = 1.0

var base_speed: float = FALL_DOWN_SPEED

func get_fall_speed() -> float:
    return self.base_speed * self.speed_multiplier
