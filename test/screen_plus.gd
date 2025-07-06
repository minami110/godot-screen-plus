# ScreenPlusプラグインのユニットテスト
extends GdUnitTestSuite

# 解像度定数が正しく定義されているかテスト
func test_all_resolution_constants_are_defined() -> void:
    assert_that(ScreenPlus.RESOLUTION_HD).is_equal(Vector2i(1280, 720))
    assert_that(ScreenPlus.RESOLUTION_FWXGA).is_equal(Vector2i(1366, 768))
    assert_that(ScreenPlus.RESOLUTION_HD_PLUS).is_equal(Vector2i(1600, 900))
    assert_that(ScreenPlus.RESOLUTION_FULL_HD).is_equal(Vector2i(1920, 1080))
    assert_that(ScreenPlus.RESOLUTION_WQHD).is_equal(Vector2i(2560, 1440))
    assert_that(ScreenPlus.RESOLUTION_QHD_PLUS).is_equal(Vector2i(3200, 1800))
    assert_that(ScreenPlus.RESOLUTION_4K).is_equal(Vector2i(3840, 2160))
    assert_that(ScreenPlus.RESOLUTION_5K).is_equal(Vector2i(5120, 2880))
    assert_that(ScreenPlus.RESOLUTION_8K).is_equal(Vector2i(7680, 4320))


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

# 最大サイズ制限が正しく機能するかテスト
func test_get_supported_resolutions_respects_max_size() -> void:
    var max_size := Vector2i(2560, 1440) # WQHD
    var resolutions := ScreenPlus.get_supported_resolutions_current_screen(max_size)

    for res in resolutions:
        if res != ScreenPlus.RESOLUTION_HD: # HD is always included as minimum
            assert_that(res.x).is_less_equal(max_size.x)
            assert_that(res.y).is_less_equal(max_size.y)

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
    assert_that(resolutions).contains([ScreenPlus.RESOLUTION_HD, ScreenPlus.RESOLUTION_FWXGA, ScreenPlus.RESOLUTION_HD_PLUS, ScreenPlus.RESOLUTION_FULL_HD, ScreenPlus.RESOLUTION_WQHD, ScreenPlus.RESOLUTION_QHD_PLUS, ScreenPlus.RESOLUTION_4K, ScreenPlus.RESOLUTION_5K, ScreenPlus.RESOLUTION_8K])
