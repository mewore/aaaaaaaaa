class_name AdvancedCamera2D

extends Camera2D

export(Curve) var SHAKE_INTENSITY_CURVE: Curve
export(float) var SHAKE_AMPLITUDE: float
export(float) var SHAKE_DURATION := 1.0

onready var SHAKE_DURATION_TIMER := $ShakeDuration

var current_amplitude: float

func _process(_delta: float) -> void:
    if not SHAKE_DURATION_TIMER.is_stopped():
        var time_ratio: float = 1.0 - SHAKE_DURATION_TIMER.time_left / SHAKE_DURATION_TIMER.wait_time
        var intensity: float = SHAKE_INTENSITY_CURVE.interpolate_baked(time_ratio) if SHAKE_INTENSITY_CURVE else 1.0
        self.offset = Vector2(randf() * current_amplitude, randf() * current_amplitude) * intensity

func shake(amplitude: float = SHAKE_AMPLITUDE) -> void:
    self.current_amplitude = amplitude
    SHAKE_DURATION_TIMER.start(SHAKE_DURATION)

func _on_ShakeDuration_timeout() -> void:
    self.offset = Vector2.ZERO
