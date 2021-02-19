class_name Log

func set_log_level(_level: String = "") -> void:
    pass

func trace(_message: String) -> void:
    pass

func debug(_message: String) -> void:
    pass

func info(_message: String) -> void:
    pass

func warn(_message: String) -> void:
    pass

func error(_message: String) -> void:
    pass

func severe(_message: String) -> void:
    pass

func check_error_code(
        _error_code: int,
        _action_description: String = "") -> void:
    pass
