class_name ScreenPlus extends Node

const __MAX_WAIT_FRAMES := 180 # 最大3秒（60FPSで180フレーム）

const RESOLUTION_HD := Vector2i(1280, 720)
const RESOLUTION_FWXGA := Vector2i(1366, 768)
const RESOLUTION_HD_PLUS := Vector2i(1600, 900)
const RESOLUTION_FULL_HD := Vector2i(1920, 1080)
const RESOLUTION_WQHD := Vector2i(2560, 1440)
const RESOLUTION_QHD_PLUS := Vector2i(3200, 1800)
const RESOLUTION_4K := Vector2i(3840, 2160)
const RESOLUTION_5K := Vector2i(5120, 2880)
const RESOLUTION_8K := Vector2i(7680, 4320)

# --------------------------------------------
# Public API
# --------------------------------------------

## スクリーンモード（ウィンドウ／フルスクリーン／排他フルスクリーン）を
## 変更し、完了まで非同期で待機する。
##
## @param target_mode 目標 WindowMode（DisplayServer.WINDOW_MODE_*）
## @param screen_id   対象スクリーン ID（フルスクリーン系のみ有意）
## @param window_size ウィンドウモード時に設定する解像度
static func set_screen_mode_async(target_mode: DisplayServer.WindowMode, screen_id: int, window_size: Vector2i) -> void:
    print("[ScreenPlus] Update Screen Mode: %s (Screen: %d / Size %s)" % [__screen_mode_to_string(target_mode), screen_id, window_size])

    match target_mode:
        DisplayServer.WINDOW_MODE_WINDOWED:
            await __set_windowed_mode_async(window_size)

        DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
            await __set_fullscreen_mode_async(target_mode, screen_id)

        _:
            push_error("[ScreenPlus] Invalid window mode: %d" % target_mode)
            return

## ウィンドウモード時、現在スクリーンの中央にウィンドウを配置する。
##
## @param window_size 現在のウィンドウサイズ（中央座標計算用）
static func move_main_window_to_screen_center() -> void:
    if __is_main_window_windowed() == false:
        push_error("[ScreenPlus] Cannot move window to center, not in windowed mode.")
        return

    # Get current mainwindow size
    var current_size := DisplayServer.window_get_size(DisplayServer.MAIN_WINDOW_ID)
    var center_pos := get_center_position_current_screen()
    var new_screen_pos := center_pos - Vector2i((current_size / 2.0).floor())
    DisplayServer.window_set_position(new_screen_pos)


## 指定したサイズ以下で利用可能な解像度のリストを取得する
## @param max_size 最大解像度（この値以下または未満の解像度を返す）
## @param inclusive trueの場合は以下、falseの場合は未満の解像度を返す（デフォルト: true）
static func get_supported_resolutions_current_screen(max_size: Vector2i, inclusive: bool = true) -> Array[Vector2i]:
    # 1280x720 (720p) を最低解像度とした, 16:9 の倍数の解像度のリスト
    # ref: https://en.wikipedia.org/wiki/16:9_aspect_ratio
    # 指定されたmax_sizeよりも小さい解像度のリストを作成する, HD は最低解像度とするので必ず入れる
    var result: Array[Vector2i] = [RESOLUTION_HD]

    const res_list: Array[Vector2i] = [RESOLUTION_FWXGA, RESOLUTION_HD_PLUS, RESOLUTION_FULL_HD, RESOLUTION_WQHD, RESOLUTION_QHD_PLUS, RESOLUTION_4K, RESOLUTION_5K, RESOLUTION_8K]
    for res in res_list:
        if inclusive:
            # 以下の場合（max_sizeを含む）
            if res.x <= max_size.x and res.y <= max_size.y:
                result.push_back(res)
        else:
            # 未満の場合（max_sizeを含まない）
            if res.x < max_size.x and res.y < max_size.y:
                result.push_back(res)

    result.make_read_only()
    return result

## 指定した解像度未満で最大の16:9解像度を取得する
## @param target_resolution 基準となる解像度
## @return 指定解像度未満の最大解像度。見つからない場合は Vector2i.ZERO を返す。
static func get_max_resolution_below(target_resolution: Vector2i) -> Vector2i:
    # すべての16:9解像度を昇順で定義
    const all_resolutions: Array[Vector2i] = [
        RESOLUTION_HD, # 1280x720
        RESOLUTION_FWXGA, # 1366x768
        RESOLUTION_HD_PLUS, # 1600x900
        RESOLUTION_FULL_HD, # 1920x1080
        RESOLUTION_WQHD, # 2560x1440
        RESOLUTION_QHD_PLUS, # 3200x1800
        RESOLUTION_4K, # 3840x2160
        RESOLUTION_5K, # 5120x2880
        RESOLUTION_8K # 7680x4320
    ]

    var max_resolution: Vector2i = Vector2i.ZERO

    # 昇順でループし、target_resolution未満の最大解像度を見つける
    for res in all_resolutions:
        if res.x < target_resolution.x and res.y < target_resolution.y:
            max_resolution = res
        else:
            # target_resolution以上になったらループを終了
            break

    return max_resolution

## 現在表示中のスクリーンの中央ピクセル座標を返す。
static func get_center_position_current_screen() -> Vector2i:
    var screen_id := DisplayServer.window_get_current_screen()
    var usable_rect := DisplayServer.screen_get_usable_rect(screen_id)
    var screen_origin := usable_rect.position
    var screen_size := usable_rect.size
    return screen_origin + Vector2i((screen_size / 2.0).floor())


# --------------------------------------------
# Private
# --------------------------------------------

## ウィンドウモードへの変更処理
static func __set_windowed_mode_async(window_size: Vector2i, centered: bool = true) -> void:
    var prev_mode := DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID)
    var prev_size := DisplayServer.window_get_size(DisplayServer.MAIN_WINDOW_ID)

    # モード変更
    if prev_mode != DisplayServer.WINDOW_MODE_WINDOWED:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.MAIN_WINDOW_ID)

    # ウィンドウモードへの変更完了を待機
    if not await __wait_for_main_window_windowed():
        push_error("[Graphics] Windowed mode change timeout")
        return

    # ウィンドウサイズ変更
    if prev_size != window_size:
        DisplayServer.window_set_size(window_size)

    # サイズ変更の完了を待機
    if not await __wait_for_main_window_size(window_size):
        push_error("[Graphics] Window size change timeout")
        return

    # ウィンドウをスクリーンの中央に移動
    if centered:
        move_main_window_to_screen_center()


## フルスクリーンモードへの変更処理
## エンジンバグ対策: スクリーン変更時は一度ウィンドウモードを経由する
## window_set_current_screen がフルスクリーンモードで正常に動作しないため、
## 別のスクリーンに移動する場合は以下の手順を実行:
## 1. 現在のモードを確認
## 2. スクリーンが異なる場合: ウィンドウモード → スクリーン変更 → 目標のフルスクリーンモード
## 3. スクリーンが同じ場合: 直接目標のフルスクリーンモードに変更
static func __set_fullscreen_mode_async(new_mode: int, screen_id: int) -> void:
    print("[ScreenPlus] Update Fullscreen Mode: %s Screen: %d" % [__screen_mode_to_string(new_mode), screen_id])

    var prev_mode := DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID)
    var prev_screen := DisplayServer.window_get_current_screen(DisplayServer.MAIN_WINDOW_ID)

    # スクリーンが存在するか確認
    if screen_id >= DisplayServer.get_screen_count():
        var primary_screen := DisplayServer.get_primary_screen()
        push_error("[Graphics] Invalid screen ID %d, Fallback primary screen %d" % [screen_id, primary_screen])
        screen_id = primary_screen

    # スクリーン移動（エンジンバグ対策）
    if prev_screen != screen_id:
        # エンジンバグ対策: window_set_current_screen は ウィンドウモードでのみ確実に動作する
        # フルスクリーンモードでのスクリーン変更は、一度ウィンドウモードを経由する必要がある
        await __set_current_screen_async(screen_id)
        prev_mode = DisplayServer.WINDOW_MODE_WINDOWED

    # モード変更（スクリーン変更が必要な場合は後で再度実行）
    if prev_mode != new_mode:
        DisplayServer.window_set_mode(new_mode, DisplayServer.MAIN_WINDOW_ID)

    # プラットフォームが待機を必要とする場合のみ待機処理を実行
    # モードとスクリーンの変更を一括で待機
    if not await __wait_for_main_window_fullscreen():
        push_error("[Graphics] Fullscreen mode change timeout")
        return


## 現在のメインウィンドウのスクリーンを非同期で変更する
## Godot 4.4 の仕様で, この関数を実行すると必ず Windowed モードに変更される
static func __set_current_screen_async(target_screen_id: int) -> void:
    # フルスクリーンモードの場合は一度ウィンドウモードにしてからスクリーン変更
    if __is_main_window_fullscreen():
        print("[Graphics] Temporarily switching to windowed mode for screen change (Engine bug workaround)")

        # 一時的にウィンドウモードに変更
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.MAIN_WINDOW_ID)

        # ウィンドウモードへの変更完了を待機
        if not await __wait_for_main_window_windowed():
            push_error("[Graphics] Failed to switch to windowed mode for screen change")
            return

    # Note: Godot 4.4 時点で, スクリーン変更はウィンドウモードのみで機能する
    # この時点では必ずウィンドウモードになっている
    # スクリーン変更を実行
    DisplayServer.window_set_current_screen(target_screen_id, DisplayServer.MAIN_WINDOW_ID)

    if not await __wait_for_main_window_screen_change(target_screen_id):
        push_error("[Graphics] Failed to change screen for main window")
        return


static func __wait_for_main_window_windowed() -> bool:
    var frame_count := 0
    while frame_count < __MAX_WAIT_FRAMES:
        if __is_main_window_windowed():
            return true

        print("[ScreenPlus] Waiting for main window to switch to windowed mode... Frame: %d" % frame_count)
        await __wait_process_frame(1)
        frame_count += 1

    push_error("[ScreenPlus] Main window did not switch to windowed mode in time.")
    return false


static func __wait_for_main_window_fullscreen() -> bool:
    var frame_count := 0
    while frame_count < __MAX_WAIT_FRAMES:
        if __is_main_window_fullscreen():
            return true

        print("[ScreenPlus] Waiting for main window to switch to fullscreen mode... Frame: %d" % frame_count)
        await __wait_process_frame(1)
        frame_count += 1

    push_error("[ScreenPlus] Main window did not switch to fullscreen mode in time.")
    return false

static func __wait_for_main_window_size(target_size: Vector2i) -> bool:
    var frame_count := 0
    while frame_count < __MAX_WAIT_FRAMES:
        var current_size := DisplayServer.window_get_size(DisplayServer.MAIN_WINDOW_ID)
        if current_size == target_size:
            return true
        print("[ScreenPlus] Waiting for main window size to change... Frame: %d Current Size: %s Target Size: %s" % [frame_count, current_size, target_size])
        await __wait_process_frame(1)
        frame_count += 1

    push_error("[ScreenPlus] Main window size did not change to %s in time." % target_size)
    return false

static func __wait_for_main_window_screen_change(target_screen: int) -> bool:
    var frame_count := 0
    while frame_count < __MAX_WAIT_FRAMES:
        if DisplayServer.window_get_current_screen(DisplayServer.MAIN_WINDOW_ID) == target_screen:
            return true

        print("[ScreenPlus] Waiting for main window to change screen... Frame: %d" % frame_count)
        await __wait_process_frame(1)
        frame_count += 1

    push_error("[ScreenPlus] Main window did not change screen in time.")
    return false

static func __is_main_window_fullscreen() -> bool:
    var mode := DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID)
    return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

static func __is_main_window_windowed() -> bool:
    return DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID) == DisplayServer.WINDOW_MODE_WINDOWED

static func __wait_process_frame(frames: int = 1) -> void:
    var scene_tree := Engine.get_main_loop()
    if scene_tree == null:
        push_error("[ScreenPlus] SceneTree is null, cannot process frames.")
        return

    if scene_tree is not SceneTree:
        push_error("[ScreenPlus] Engine main loop is not a SceneTree instance.")
        return

    for i in range(frames):
        await scene_tree.process_frame

static func __screen_mode_to_string(mode: int) -> String:
    match mode:
        DisplayServer.WINDOW_MODE_WINDOWED:
            return "Windowed"
        DisplayServer.WINDOW_MODE_FULLSCREEN:
            return "Fullscreen"
        DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
            return "Exclusive Fullscreen"
        _:
            return "WindowMode(%d)" % mode
