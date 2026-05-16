// This file contains the implementation for the insertion sort algorithm.
//
// Insertion sort sorts the xs array in place by examining each element, considering the elements
// on its left to be in order and moving backward, exchanging the element with the one considered
// as long as the element is smaller than the considered element.
//
// The sort is stable.
// Its performance is O(N^2).
// It can be faster than selection sort
// if the original array is partially sorted.
package midgard

import "base:intrinsics"
import "core:testing"


// Sort the xs slice in-place.
insertion_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if !(xs[j] < xs[j - 1]) {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

// Sort the xs slice in place, using the `less()` procedure
//  parameter to compare elements.
insertion_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if !less(xs[j], xs[j - 1]) {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_insertion_sort :: proc(t: ^testing.T) {

	insertion_sort_int :: proc(xs: []int) {insertion_sort(xs)}

	test_sort_int_helper(t, insertion_sort_int)
}

@(test)
test_insertion_sort_large :: proc(t: ^testing.T) {

	insertion_sort_f64 :: proc(xs: []f64) {insertion_sort(xs)}

	test_sort_float_helper(t, insertion_sort_f64)
}

@(test)
test_insertion_sort_by :: proc(t: ^testing.T) {

	insertion_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		insertion_sort_by(xs, less)
	}

	test_sort_by_string_helper(t, insertion_sort_string_by)
}

@(test)
test_insertion_sort_by_reverse :: proc(t: ^testing.T) {

	insertion_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		insertion_sort_by(xs, less)
	}

	test_sort_by_string_reverse_helper(t, insertion_sort_string_by)
}

