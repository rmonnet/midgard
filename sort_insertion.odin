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


// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
insertion_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if cmp(xs[j], xs[j - 1]) != .Less {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_insertion_sort :: proc(t: ^testing.T) {

	insertion_sort_int :: proc(xs: []int) {insertion_sort(xs, cmp_int)}

	test_sort_int_helper(t, insertion_sort_int)
}

@(test)
test_insertion_sort_f64 :: proc(t: ^testing.T) {

	insertion_sort_f64 :: proc(xs: []f64) {insertion_sort(xs, cmp_f64)}

	test_sort_float_helper(t, insertion_sort_f64)
}

@(test)
test_insertion_sort_string :: proc(t: ^testing.T) {

	insertion_sort_string :: proc(xs: []string) {insertion_sort(xs, cmp_string)}

	test_sort_string_helper(t, insertion_sort_string)
}

@(test)
test_insertion_sort_string_reverse :: proc(t: ^testing.T) {

	insertion_sort_string_reverse :: proc(xs: []string) {insertion_sort(xs, cmp_string_reverse)}

	test_sort_string_reverse_helper(t, insertion_sort_string_reverse)
}

