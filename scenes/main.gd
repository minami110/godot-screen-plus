extends Control

func _ready() -> void:
    %SetWindowedButton.pressed.connect(func() -> void:
        ScreenPlus.set_screen_mode_async(
            DisplayServer.WINDOW_MODE_WINDOWED,
            0,
            Vector2i(1280, 720),
        )
    )

    var screen_count := DisplayServer.get_screen_count()
    for i in range(screen_count):
        var b1 := Button.new()
        b1.text = "Set Fullscreen (Monitor: %d)" % i
        b1.pressed.connect(func() -> void:
            ScreenPlus.set_screen_mode_async(
                DisplayServer.WINDOW_MODE_FULLSCREEN,
                i,
                Vector2i(1920, 1080)
            )
        )
        $VBoxContainer.add_child(b1)

        var b2 := Button.new()
        b2.text = "Set Exclusive Fullscreen (Monitor: %d)" % i
        b2.pressed.connect(func() -> void:
            ScreenPlus.set_screen_mode_async(
                DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
                i,
                Vector2i(1920, 1080)
            )
        )
        $VBoxContainer.add_child(b2)
