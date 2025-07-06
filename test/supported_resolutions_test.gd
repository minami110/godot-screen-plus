# サポート解像度取得機能のユニットテスト
extends GdUnitTestSuite

# サポート解像度の取得が配列を返すかテスト
func test_get_supported_resolutions_returns_array() -> void:
    var max_size := Vector2i(1920, 1080)
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)
    assert_that(resolutions).is_not_null()
    assert_bool(resolutions.is_read_only()).is_true()


# 最小解像度としてHDが含まれるかテスト
func test_get_supported_resolutions_includes_hd_as_minimum() -> void:
    var max_size := Vector2i(1920, 1080)
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)
    assert_that(resolutions[0]).is_equal(ScreenPlus.RESOLUTION_HD)

# 解像度がサイズ順にソートされているかテスト
func test_get_supported_resolutions_are_sorted_by_size() -> void:
    var max_size := Vector2i(3840, 2160) # 4K
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)
    for i in range(1, resolutions.size()):
        var prev_res := resolutions[i - 1]
        var curr_res := resolutions[i]
        assert_that(curr_res.x).is_greater_equal(prev_res.x)
        assert_that(curr_res.y).is_greater_equal(prev_res.y)

# 最大サイズ制限が正しく機能するかテスト（inclusive = true）
func test_get_supported_resolutions_respects_max_size_inclusive() -> void:
    var max_size := Vector2i(2560, 1440) # WQHD
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size, true)

    for res in resolutions:
        if res != ScreenPlus.RESOLUTION_HD: # HD is always included as minimum
            assert_that(res.x).is_less_equal(max_size.x)
            assert_that(res.y).is_less_equal(max_size.y)

    # WQHDが含まれるべき（以下なので）
    assert_that(resolutions).contains([ScreenPlus.RESOLUTION_WQHD])

# 最大サイズ制限が正しく機能するかテスト（inclusive = false）
func test_get_supported_resolutions_respects_max_size_exclusive() -> void:
    var max_size := Vector2i(2560, 1440) # WQHD
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size, false)

    for res in resolutions:
        if res != ScreenPlus.RESOLUTION_HD: # HD is always included as minimum
            assert_that(res.x).is_less(max_size.x)
            assert_that(res.y).is_less(max_size.y)

    # WQHDは含まれないべき（未満なので）
    assert_that(resolutions).not_contains([ScreenPlus.RESOLUTION_WQHD])

# 小さい最大サイズでの動作テスト
func test_get_supported_resolutions_with_small_max_size() -> void:
    var max_size := Vector2i(1280, 720) # HDと同じ
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)
    # HDは最低解像度なので必ず含まれる
    assert_that(resolutions).has_size(1)
    assert_that(resolutions[0]).is_equal(ScreenPlus.RESOLUTION_HD)

# 大きい最大サイズでの動作テスト
func test_get_supported_resolutions_with_large_max_size() -> void:
    var max_size := Vector2i(7680, 4320) # 8K
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)
    # すべての定義された解像度が含まれる
    assert_that(resolutions).contains([
        ScreenPlus.RESOLUTION_HD,
        ScreenPlus.RESOLUTION_FWXGA,
        ScreenPlus.RESOLUTION_HD_PLUS,
        ScreenPlus.RESOLUTION_FULL_HD,
        ScreenPlus.RESOLUTION_WQHD,
        ScreenPlus.RESOLUTION_QHD_PLUS,
        ScreenPlus.RESOLUTION_4K,
        ScreenPlus.RESOLUTION_5K,
        ScreenPlus.RESOLUTION_8K
    ])

# Full HD未満の解像度を取得するテスト
func test_get_supported_resolutions_below_full_hd() -> void:
    var max_size := ScreenPlus.RESOLUTION_FULL_HD
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size, false)

    # Full HDは含まれない
    assert_that(resolutions).not_contains([ScreenPlus.RESOLUTION_FULL_HD])
    # HD_PLUSまでが含まれる
    assert_that(resolutions).contains([
        ScreenPlus.RESOLUTION_HD,
        ScreenPlus.RESOLUTION_FWXGA,
        ScreenPlus.RESOLUTION_HD_PLUS
    ])

# Full HD以下の解像度を取得するテスト
func test_get_supported_resolutions_including_full_hd() -> void:
    var max_size := ScreenPlus.RESOLUTION_FULL_HD
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size, true)

    # Full HDが含まれる
    assert_that(resolutions).contains([ScreenPlus.RESOLUTION_FULL_HD])
    # Full HD以下すべてが含まれる
    assert_that(resolutions).contains([
        ScreenPlus.RESOLUTION_HD,
        ScreenPlus.RESOLUTION_FWXGA,
        ScreenPlus.RESOLUTION_HD_PLUS,
        ScreenPlus.RESOLUTION_FULL_HD
    ])
