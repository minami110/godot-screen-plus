extends Label

func _process(_delta: float) -> void:
    var info := "----- System Information -----\n"

    # Get the OS
    var os_name := OS.get_name()
    info += "Operating System: %s\n" % os_name

    # Get the display server name
    var display_server_name := DisplayServer.get_name()
    info += "Display Server: %s\n" % display_server_name

    # Get the current screen count
    var screen_count := DisplayServer.get_screen_count()
    info += "Total Screen Count: %d\n" % screen_count

    # Get the primary screen ID
    var primary_screen := DisplayServer.get_primary_screen()
    info += "Primary Screen ID: %d\n" % primary_screen

    info += "----- Current Window Information -----\n"
    var current_mode := DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID)
    if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
        info += "Current Window Mode: Windowed\n"
    elif current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
        info += "Current Window Mode: Fullscreen\n"
    elif current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
        info += "Current Window Mode: Exclusive Fullscreen\n"
    else:
        info += "Current Window Mode: Unknown (%d)\n" % current_mode

    # Get the current screen ID
    var current_screen := DisplayServer.window_get_current_screen(DisplayServer.MAIN_WINDOW_ID)
    info += "Current Screen ID: %d\n" % current_screen

    # Get the current window mode
    var window_size := DisplayServer.window_get_size(DisplayServer.MAIN_WINDOW_ID)
    info += "Current Window Resolution: %dx%d\n" % [window_size.x, window_size.y]

    # Get the current window position
    var window_position := DisplayServer.window_get_position(DisplayServer.MAIN_WINDOW_ID)
    info += "Current Window Position: (%d, %d)\n" % [window_position.x, window_position.y]

    # Screen info
    for i in range(screen_count):
        info += "----- Screen %d -----\n" % i

        # size
        var screen_size := DisplayServer.screen_get_size(i)
        info += "Size: %dx%d\n" % [screen_size.x, screen_size.y]

        # position
        var screen_position := DisplayServer.screen_get_position(i)
        info += "Position: (%d, %d)\n" % [screen_position.x, screen_position.y]

        var screen_rect := DisplayServer.screen_get_usable_rect(i)
        info += "Usable Rect: %dx%d at (%d, %d)\n" % [screen_rect.size.x, screen_rect.size.y, screen_rect.position.x, screen_rect.position.y]


    text = info
