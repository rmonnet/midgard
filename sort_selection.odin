// This file contains the implementation for the selection sort algorithm.
package midgard

import "base:intrinsics"
import "core:testing"

// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// Its performance is O(N^2).
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

// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right using the
// procedure less for comparison.
//
// Its performance is O(N^2).
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
	test_sort_int_helper(t, proc(xs: []int) {selection_sort(xs)})
}

@(test)
test_selection_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {selection_sort(xs)})
}

@(test)
test_selection_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {selection_sort_by(xs, less)},
	)
}

