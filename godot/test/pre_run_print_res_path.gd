extends GutHookScript

func run():
    var res_root = "res://"
    var user_root = "user://"

    var res_abs = ProjectSettings.globalize_path(res_root)
    var user_abs = ProjectSettings.globalize_path(user_root)

    var example_file = "res://test/res/tile_type.tres"
    var example_exists = FileAccess.file_exists(example_file)

    var lines = []
    lines.append(str("GUT pre-run hook: res:// -> ", res_abs))
    lines.append(str("GUT pre-run hook: user:// -> ", user_abs))
    lines.append(str("OS.get_user_data_dir(): ", OS.get_user_data_dir()))
    lines.append(str(example_file, " exists: ", example_exists))

    for l in lines:
        print(l)
        if gut != null and gut.logger != null:
            gut.logger.log(l)

    # No special async work required; return to let GUT continue.
    return
