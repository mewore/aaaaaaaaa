class_name GameSettings

const AUDIO_MIN_DB := -40.0
const AUDIO_MAX_DB := 0.0

const SFX_AUDIO_BUS_INDEX := 1

const DEFAULT_SFX_VOLUME_DB := -30.0

var sfx_volume_db: float = DEFAULT_SFX_VOLUME_DB setget set_sfx_volume_db

func set_sfx_volume_db(new_sfx_volume_db: float) -> void:
    sfx_volume_db = new_sfx_volume_db
    AudioServer.set_bus_volume_db(SFX_AUDIO_BUS_INDEX, sfx_volume_db)

func get_sfx_volume_ratio() -> float:
    return inverse_lerp(AUDIO_MIN_DB, AUDIO_MAX_DB, sfx_volume_db)

func set_sfx_volume_ratio(ratio: float) -> void:
    self.sfx_volume_db = lerp(AUDIO_MIN_DB, AUDIO_MAX_DB, ratio)

func as_dictionary() -> Dictionary:
    return {
        "sfx_volume_db": self.sfx_volume_db,
    }

func initialize_from_dictionary(dictionary: Dictionary) -> void:
    self.sfx_volume_db = dictionary.get("sfx_volume_db", DEFAULT_SFX_VOLUME_DB) as float
