extends Node

var LOG: Log = LogManager.get_log(self)

const SAVE_DIRECTORY = "user://"
const SAVE_FILE_PREFIX = "save-"
const SAVE_FILE_SUFFIX = ".json"

const DEFAULT_SAVE_FILE := "default";

var game_data: Dictionary = {}

func get_world_info() -> WorldInfo:
    return get_tree().get_nodes_in_group("world_info").front()

func new_game() -> void:
    self.game_data = {}

func save_game(save_name: String, save_to_overwrite: String = "") -> void:
    for _node in get_tree().get_nodes_in_group("saveable"):
        var node := _node as Node
        if node.has_method("save_data"):
            node.save_data()

    for _key in game_data.keys():
        var key := _key as String
        var value = game_data.get(key)
        if value is Dictionary:
            var dict := value as Dictionary
            if dict.empty():
                if not game_data.erase(key):
                    print("Tried to erase a non-existent game data key '%s'!" % key)

    var new_save_file_name: String = SAVE_DIRECTORY + "/" + SAVE_FILE_PREFIX + save_name + SAVE_FILE_SUFFIX
    
    var file: File = File.new()
    LOG.check_error_code(file.open(new_save_file_name, File.WRITE), "Opening '%s'" % new_save_file_name)
    LOG.info("Saving to: " + file.get_path_absolute())
    file.store_string(to_json(game_data))
    file.close()
    
    if not save_to_overwrite.empty() and save_to_overwrite != save_name:
        var dir: Directory = self.open_save_directory()
        var old_save_file_name: String = SAVE_FILE_PREFIX + save_to_overwrite + SAVE_FILE_SUFFIX
        if dir.file_exists(old_save_file_name):
            LOG.check_error_code(dir.remove(old_save_file_name), "Removing '%s'" % [old_save_file_name])

func get_save_files() -> PoolStringArray:
    var dir: Directory = self.open_save_directory()
    LOG.check_error_code(dir.list_dir_begin(false, false), "Listing the files of " + SAVE_DIRECTORY)
    var file_name: String = dir.get_next()
    
    var result: Array = []
    while file_name != "":
        if not dir.current_is_dir() and file_name.begins_with(SAVE_FILE_PREFIX) \
                and file_name.ends_with(SAVE_FILE_SUFFIX):
            result.append(file_name.substr(SAVE_FILE_PREFIX.length(),
                file_name.length() - SAVE_FILE_PREFIX.length() - SAVE_FILE_SUFFIX.length()))
        file_name = dir.get_next()
    dir.list_dir_end()

    result.sort()
    return PoolStringArray(result)

func get_single_node_in_group(group: String) -> Node:
    return get_tree().get_nodes_in_group(group).front()

func open_save_directory() -> Directory:
    var dir: Directory = Directory.new()
    LOG.check_error_code(dir.open(SAVE_DIRECTORY), "Opening " + SAVE_DIRECTORY)
    return dir

func load_game(save_name: String) -> void:
    var file = File.new()
    var save_file_path: String = SAVE_DIRECTORY + "/" + SAVE_FILE_PREFIX + save_name + SAVE_FILE_SUFFIX
    if not file.file_exists(save_file_path):
        LOG.error("No such file: " + save_file_path)
        return

    LOG.check_error_code(file.open(save_file_path, File.READ), "Opening file " + save_file_path)
    var loaded_data = parse_json(file.get_as_text())
    file.close()
    if loaded_data is Dictionary:
        game_data = loaded_data
    else:
        LOG.error("Corrupted savegame data!")
