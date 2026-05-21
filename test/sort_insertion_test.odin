package test

import alg ".."
import "core:testing"

@(test)
test_insertion_sort_int :: proc(t: ^testing.T) {

	insertion_sort_int :: proc(xs: []int) {alg.insertion_sort(xs, cmp_int)}
	test_sort_int_helper(t, insertion_sort_int)
}

@(test)
test_insertion_sort_f64 :: proc(t: ^testing.T) {

	insertion_sort_f64 :: proc(xs: []f64) {alg.insertion_sort(xs, cmp_f64)}
	test_sort_float_helper(t, insertion_sort_f64)
}

@(test)
test_insertion_sort_string :: proc(t: ^testing.T) {

	insertion_sort_string :: proc(xs: []string) {alg.insertion_sort(xs, cmp_string)}
	test_sort_string_helper(t, insertion_sort_string)
}

@(test)
test_insertion_sort_string_rev :: proc(t: ^testing.T) {

	insertion_sort_string_rev :: proc(xs: []string) {alg.insertion_sort(xs, cmp_string_rev)}
	test_sort_string_reverse_helper(t, insertion_sort_string_rev)
}

