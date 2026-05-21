package test

import alg ".."
import "core:testing"

@(test)
test_selection_sort_int :: proc(t: ^testing.T) {

	selection_sort_int :: proc(xs: []int) {alg.selection_sort(xs, cmp_int)}
	test_sort_int_helper(t, selection_sort_int)
}

@(test)
test_selection_sort_f64 :: proc(t: ^testing.T) {

	selection_sort_f64 :: proc(xs: []f64) {alg.selection_sort(xs, cmp_f64)}
	test_sort_float_helper(t, selection_sort_f64)
}

@(test)
test_selection_sort_string :: proc(t: ^testing.T) {

	selection_sort_string :: proc(xs: []string) {alg.selection_sort(xs, cmp_string)}
	test_sort_string_helper(t, selection_sort_string)
}

@(test)
test_selection_sort_string_rev :: proc(t: ^testing.T) {

	selection_sort_string_rev :: proc(xs: []string) {alg.selection_sort(xs, cmp_string_rev)}
	test_sort_string_reverse_helper(t, selection_sort_string_rev)
}

