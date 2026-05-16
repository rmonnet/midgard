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

// Sort the xs slice in-place.
selection_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if xs[j] < xs[min_j] {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

// Sort the xs slice in place, using the `less()` procedure
//  parameter to compare elements.
selection_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if less(xs[j], xs[min_j]) {
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
test_selection_sort :: proc(t: ^testing.T) {

	selection_sort_int :: proc(xs: []int) {selection_sort(xs)}

	test_sort_int_helper(t, selection_sort_int)
}

@(test)
test_selection_sort_large :: proc(t: ^testing.T) {

	selection_sort_f64 :: proc(xs: []f64) {selection_sort(xs)}

	test_sort_float_helper(t, selection_sort_f64)
}

@(test)
test_selection_sort_by :: proc(t: ^testing.T) {

	selection_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		selection_sort_by(xs, less)
	}

	test_sort_by_string_helper(t, selection_sort_string_by)
}

@(test)
test_selection_sort_by_reverse :: proc(t: ^testing.T) {

	selection_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		selection_sort_by(xs, less)
	}

	test_sort_by_string_reverse_helper(t, selection_sort_string_by)
}

