class_name TimeLabel

extends Label

signal updated(total_seconds_left)

const EPSILON := 1e-10

onready var UPDATE_TIMER := $Update as Timer
onready var INITIAL_TEXT := self.text

var timer: Timer setget set_timer

func set_timer(new_timer: Timer) -> void:
    timer = new_timer
    if timer:
        self.update()
    else:
        self.revert_to_default()

func _ready() -> void:
    if self.timer:
        self.update()

func update() -> void:
    if not self.timer:
        return
    if self.timer.is_stopped():
        self.timer = null
        self.revert_to_default()
        return
    
    var time_left: float = self.timer.time_left
    # Decrease the time that is left by a tiny amount because otherwise on the first second there's 100% time left and
    # on the next second there are two less seconds left
    var total_seconds_left := int(floor(time_left - EPSILON))
    var minutes_left := int(float(total_seconds_left) / 60)
    var seconds_left := total_seconds_left % 60
    self.text = "%d%d:%d%d" % [int(float(minutes_left) / 10), minutes_left % 10,
        int(float(seconds_left) / 10), seconds_left % 10]

    var time_until_next_round_second: float = fmod(time_left, 1.0)
    UPDATE_TIMER.start(1.0 if is_zero_approx(time_until_next_round_second) else time_until_next_round_second)
    emit_signal("updated", total_seconds_left)

func revert_to_default() -> void:
    UPDATE_TIMER.stop()
    self.text = INITIAL_TEXT

func _on_Update_timeout() -> void:
    self.update()
