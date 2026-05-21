package test

import alg ".."
import "core:testing"

@(test)
test_bottom_merge_sort_int :: proc(t: ^testing.T) {

	bottom_merge_sort_int :: proc(xs: []int) {alg.bottom_merge_sort(xs, cmp_int)}
	test_sort_int_helper(t, bottom_merge_sort_int)
}

@(test)
test_bottom_merge_sort_f64 :: proc(t: ^testing.T) {

	bottom_merge_sort_f64 :: proc(xs: []f64) {alg.bottom_merge_sort(xs, cmp_f64)}
	test_sort_float_helper(t, bottom_merge_sort_f64)
}

@(test)
test_bottom_merge_sort_string :: proc(t: ^testing.T) {

	bottom_merge_sort_string :: proc(xs: []string) {alg.bottom_merge_sort(xs, cmp_string)}
	test_sort_string_helper(t, bottom_merge_sort_string)
}

@(test)
test_bottom_merge_sort_by_rev :: proc(t: ^testing.T) {

	bottom_merge_sort_string_rev :: proc(xs: []string) {alg.bottom_merge_sort(xs, cmp_string_rev)}
	test_sort_string_reverse_helper(t, bottom_merge_sort_string_rev)
}

