package test

import alg ".."
import "core:testing"


@(test)
test_quick_sort_int :: proc(t: ^testing.T) {

	quick_sort_int :: proc(xs: []int) {alg.quick_sort(xs, cmp_int)}
	test_sort_int_helper(t, quick_sort_int)
}

@(test)
test_quick_sort_f64 :: proc(t: ^testing.T) {

	quick_sort_f64 :: proc(xs: []f64) {alg.quick_sort(xs, cmp_f64)}
	test_sort_float_helper(t, quick_sort_f64)
}

@(test)
test_quick_sort_string :: proc(t: ^testing.T) {

	quick_sort_string :: proc(xs: []string) {alg.quick_sort(xs, cmp_string)}
	test_sort_string_helper(t, quick_sort_string)
}

@(test)
test_quick_sort_string_rev :: proc(t: ^testing.T) {

	quick_sort_string_rev :: proc(xs: []string) {alg.quick_sort(xs, cmp_string_rev)}
	test_sort_string_reverse_helper(t, quick_sort_string_rev)
}

@(test)
test_median_of_3 :: proc(t: ^testing.T) {

	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 0, 1, 2, cmp_int), 1)
	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 0, 2, 1, cmp_int), 1)
	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 1, 0, 2, cmp_int), 1)
	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 1, 2, 0, cmp_int), 1)
	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 2, 0, 1, cmp_int), 1)
	testing.expect_value(t, alg.median_index_of_3([]int{11, 12, 13}, 2, 1, 0, cmp_int), 1)
}

@(test)
test_quick_select :: proc(t: ^testing.T) {

	quick_select_int :: proc(xs: []int, k: int) -> int {return alg.quick_select(xs, k, cmp_int)}

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	// the sorted array:
	// {1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	testing.expect_value(t, quick_select_int(xs, 0), 1)
	testing.expect_value(t, quick_select_int(xs, 21), 20)
	testing.expect_value(t, quick_select_int(xs, 10), 10)
}

@(test)
test_three_way_quick_sort_int :: proc(t: ^testing.T) {

	three_way_quick_sort_int :: proc(xs: []int) {alg.three_way_quick_sort(xs, cmp_int)}
	test_sort_int_helper(t, three_way_quick_sort_int)
}

@(test)
test_three_way_quick_sort_f64 :: proc(t: ^testing.T) {

	three_way_quick_sort_f64 :: proc(xs: []f64) {alg.three_way_quick_sort(xs, cmp_f64)}
	test_sort_float_helper(t, three_way_quick_sort_f64)
}

@(test)
test_three_way_quick_sort_string :: proc(t: ^testing.T) {

	three_way_quick_sort_string :: proc(xs: []string) {alg.three_way_quick_sort(xs, cmp_string)}
	test_sort_string_helper(t, three_way_quick_sort_string)
}

@(test)
test_three_way_quick_sort_string_rev :: proc(t: ^testing.T) {
	three_way_quick_sort_string_rev :: proc(xs: []string) {alg.three_way_quick_sort(
			xs,
			cmp_string_rev,
		)}
	test_sort_string_reverse_helper(t, three_way_quick_sort_string_rev)
}

