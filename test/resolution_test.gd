# 解像度関連のユニットテスト
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

# get_max_resolution_below のテスト
func test_get_max_resolution_below_full_hd() -> void:
    # Full HDより下の最大解像度はHD_PLUS
    var result: Variant = ScreenPlus.get_max_resolution_below(ScreenPlus.RESOLUTION_FULL_HD)
    assert_that(result).is_equal(ScreenPlus.RESOLUTION_HD_PLUS)

func test_get_max_resolution_below_hd_plus() -> void:
    # HD_PLUSより下の最大解像度はFWXGA
    var result: Variant = ScreenPlus.get_max_resolution_below(ScreenPlus.RESOLUTION_HD_PLUS)
    assert_that(result).is_equal(ScreenPlus.RESOLUTION_FWXGA)

func test_get_max_resolution_below_hd() -> void:
    # HDより下の解像度は存在しないのでnull
    var result: Variant = ScreenPlus.get_max_resolution_below(ScreenPlus.RESOLUTION_HD)
    assert_that(result).is_null()

func test_get_max_resolution_below_custom_resolution() -> void:
    # カスタム解像度（1920x1080）の場合
    var custom_resolution := Vector2i(1920, 1080)
    var result: Variant = ScreenPlus.get_max_resolution_below(custom_resolution)
    assert_that(result).is_equal(ScreenPlus.RESOLUTION_HD_PLUS)

func test_get_max_resolution_below_between_resolutions() -> void:
    # 解像度の間の値（2000x1200）の場合
    var custom_resolution := Vector2i(2000, 1200)
    var result: Variant = ScreenPlus.get_max_resolution_below(custom_resolution)
    assert_that(result).is_equal(ScreenPlus.RESOLUTION_FULL_HD)

func test_get_max_resolution_below_very_small() -> void:
    # 非常に小さい解像度（800x600）の場合
    var small_resolution := Vector2i(800, 600)
    var result: Variant = ScreenPlus.get_max_resolution_below(small_resolution)
    assert_that(result).is_null()