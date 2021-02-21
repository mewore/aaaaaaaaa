extends PlayerState

onready var DURATION_TIMER := $Duration as Timer
onready var DEATH_SOUND := $DeathSound as AudioStreamPlayer

func enter() -> void:
    self.player.invulnerable = true
    DURATION_TIMER.start()
    self.player.CAMERA.position = Vector2.ZERO
    self.player.megumin()
    DEATH_SOUND.play()

func exit() -> void:
    self.player.invulnerable = false
    DURATION_TIMER.stop()

func _on_Duration_timeout() -> void:
    if self.active:
        self.next_state = DEAD
