extends PlayerState

onready var SCREAM_CLEAR_TIMER := $ScreamClear

const HP_LOST_PER_SECOND := 0.05

func process(delta: float) -> void:
    self.player.hp -= delta * HP_LOST_PER_SECOND
    if self.player.hp < 0.0:
        self.player.hp = 0.0
        self.next_state = DYING

func physics_process(delta: float) -> void:
    self.player.move(delta)

func unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("scream"):
        var scream_heal := self.player.add_scream()
        SCREAM_CLEAR_TIMER.start()
        self.player.hp = min(self.player.hp + scream_heal, Player.MAX_HP)
    else:
        self.player.handle_jump_control(event)

func _on_Player_reached_win_area() -> void:
    self.next_state = WINNING

func _on_ScreamClear_timeout() -> void:
    if self.active:
        self.player.clear_scream()
