extends PlayerState

onready var DURATION_TIMER = $Duration as Timer
onready var LEVEL_CLEARED_SOUND := $LevelClearedSound as AudioStreamPlayer

func enter() -> void:
    self.player.invulnerable = true
    DURATION_TIMER.start()
    self.player.celebrate()
    LEVEL_CLEARED_SOUND.play()

func exit() -> void:
    self.player.invulnerable = false
    DURATION_TIMER.stop()

func _on_Duration_timeout() -> void:
    self.player.win()
