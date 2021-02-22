extends PlayerState

onready var SCREAM_CLEAR_TIMER := $ScreamClear as Timer
onready var AUTO_SCREAM_TIMER := $AutoScream as Timer
onready var SCREAM_SOUND_SMALL := $ScreamSmallSound as AudioStreamPlayer
onready var SCREAM_SOUND_BIG := $ScreamBigSound as AudioStreamPlayer

const HP_LOST_PER_SECOND := 0.05
const HP_LOST_PER_DAMAGE_PER_SECOND := 0.02

func process(delta: float) -> void:
    self.player.hp -= delta * HP_LOST_PER_SECOND
    self.player.hp -= delta * self.player.damage_taken * HP_LOST_PER_DAMAGE_PER_SECOND
    if self.player.hp < 0.0:
        self.player.hp = 0.0
        self.next_state = DYING

func physics_process(delta: float) -> void:
    self.player.move(delta)

func unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("scream"):
        AUTO_SCREAM_TIMER.start()
        self.perform_the_forbidden_art_of_screaming()
    elif event.is_action_released("scream"):
        AUTO_SCREAM_TIMER.stop()
    else:
        self.player.handle_jump_control(event)

func _on_Player_reached_win_area() -> void:
    self.next_state = WINNING

func _on_ScreamClear_timeout() -> void:
    if self.active:
        self.player.clear_scream()

func _on_AutoScream_timeout():
    if self.active and Input.is_action_pressed("scream"):
        self.perform_the_forbidden_art_of_screaming()
    else:
        AUTO_SCREAM_TIMER.stop()

func perform_the_forbidden_art_of_screaming() -> void:
    var scream_heal := self.player.add_scream()
    SCREAM_CLEAR_TIMER.start()
    self.player.hp = min(self.player.hp + scream_heal, Player.MAX_HP)
    (SCREAM_SOUND_BIG if self.player.has_big_screams() else SCREAM_SOUND_SMALL).play()
