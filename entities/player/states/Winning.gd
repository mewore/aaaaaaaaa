extends PlayerState

onready var DURATION_TIMER: Timer = $Duration

func enter() -> void:
    self.player.invulnerable = true
    DURATION_TIMER.start()
    self.player.celebrate()

func exit() -> void:
    self.player.invulnerable = false
    DURATION_TIMER.stop()

func _on_Duration_timeout() -> void:
    self.player.win()
