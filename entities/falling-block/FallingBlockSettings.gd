class_name FallingBlockSettings

extends Node

const DEFAULT_FALL_SPEED: float = 50.0

# For pausing
export(float, 0.0, 1.0) var speed_multiplier: float = 1.0

var base_speed: float = DEFAULT_FALL_SPEED

func get_fall_speed() -> float:
    return self.base_speed * self.speed_multiplier
