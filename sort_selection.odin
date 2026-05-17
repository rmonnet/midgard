// This file contains the implementation for the selection sort algorithm.
//
// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// The sort is not stable.
// Its performance is O(N^2).
package midgard

import "base:intrinsics"
import "core:testing"

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
selection_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if cmp(xs[j], xs[min_j]) == .Less {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------


@(test)
test_selection_sort_int :: proc(t: ^testing.T) {

	selection_sort_int :: proc(xs: []int) {selection_sort(xs, cmp_int)}

	test_sort_int_helper(t, selection_sort_int)
}

@(test)
test_selection_sort_f64 :: proc(t: ^testing.T) {

	selection_sort_f64 :: proc(xs: []f64) {selection_sort(xs, cmp_f64)}

	test_sort_float_helper(t, selection_sort_f64)
}

@(test)
test_selection_sort_string :: proc(t: ^testing.T) {

	selection_sort_string :: proc(xs: []string) {selection_sort(xs, cmp_string)}

	test_sort_string_helper(t, selection_sort_string)
}

@(test)
test_selection_sort_string_reverse :: proc(t: ^testing.T) {

	selection_sort_string_reverse :: proc(xs: []string) {selection_sort(xs, cmp_string_reverse)}

	test_sort_string_reverse_helper(t, selection_sort_string_reverse)
}

