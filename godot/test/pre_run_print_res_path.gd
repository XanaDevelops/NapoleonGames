extends GutHookScript

func _log(msg):
	print(msg)
	if gut != null and gut.logger != null:
		gut.logger.log(msg)

func run():
	var candidates = [
		"res://test/res",
		"user://test/res",
		OS.get_user_data_dir().path_join("test/res"),
        "/tmp/test/res"
	]

	_log(str("GUT pre-run: OS.get_user_data_dir(): ", OS.get_user_data_dir()))

	var selected_path = ""
	var timestamp = str(Time.get_unix_time_from_system())

	for cand in candidates:
		var display = cand
		var abs_path = cand
		if cand.begins_with("res://") or cand.begins_with("user://"):
			abs_path = ProjectSettings.globalize_path(cand)

		# Ensure directory exists (recursive)
		var mk_err = DirAccess.make_dir_recursive_absolute(abs_path)

		var test_file = abs_path.path_join("_gut_write_test_" + timestamp + ".tmp")
		var writable = false
		var open_err = null
		var f = FileAccess.open(test_file, FileAccess.WRITE)
		open_err = FileAccess.get_open_error()
		if open_err == OK and f != null:
			f.store_string("GUT write test\n")
			f = null
			writable = true

			# try to remove the test file
			var d = DirAccess.open(test_file.get_base_dir())
			if d != null:
				d.remove(test_file)

		var msg = str("Write check: ", display, " -> ", abs_path, " writable: ", writable, " mkdir_err: ", mk_err, " open_err: ", open_err)
		_log(msg)

		if writable and selected_path == "":
			selected_path = cand
			# try to export as environment variable for other scripts
			if OS.has_method("set_environment"):
				OS.set_environment("TEST_PATH", selected_path)
				_log(str("Set environment TEST_PATH=", selected_path))

			# write fallback marker file in user:// so tests can read it
			var marker_rel = "user://test/TEST_PATH.txt"
			var marker_abs = ProjectSettings.globalize_path(marker_rel)
			DirAccess.make_dir_recursive_absolute(marker_abs.get_base_dir())
			var mf = FileAccess.open(marker_abs, FileAccess.WRITE)
			if mf != null:
				mf.store_string(selected_path)
				mf = null
			break

	if selected_path == "":
		_log("No writable test path found from candidates.")
	else:
		_log(str("Selected TEST_PATH: ", selected_path))

	return
