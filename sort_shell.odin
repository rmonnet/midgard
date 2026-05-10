// This file contains the implementation for the shell sort algorithm.
package midgard

import "base:intrinsics"
import "core:testing"

// Shell sort sorts the xs array as an h array
// (that is considering only the h-th elements of the array)
// using insertion sort. It then continues to do so while
// decreasing the value of h down to 1.
//
// This is efficient because 1) the h-array stays sorted as we decrease
// the value of h and 2) insertion sort is efficient when used with partially
// sorted arrays.
shell_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	h := 1
	for h < len(xs) / 3 {
		h = 3 * h + 1
	}
	for ; h >= 1; h = h / 3 {
		for i := h; i < len(xs); i += 1 {
			for j := i; j >= h; j -= h {
				if !(xs[j] < xs[j - h]) {break}
				xs[j], xs[j - h] = xs[j - h], xs[j]
			}
		}
	}
}

// Shell sort sorts the xs array as an h array
// (that is considering only the h-th elements of the array)
// using insertion sort. It then continues to do so while
// decreasing the value of h down to 1. It uses the procedure less when
// comparing the elements.
//
// This is efficient because 1) the h-array stays sorted as we decrease
// the value of h and 2) insertion sort is efficient when used with partially
// sorted arrays.
shell_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	h := 1
	for h < len(xs) / 3 {
		h = 3 * h + 1
	}
	for ; h >= 1; h = h / 3 {
		for i := h; i < len(xs); i += 1 {
			for j := i; j >= h; j -= h {
				if !less(xs[j], xs[j - h]) {break}
				xs[j], xs[j - h] = xs[j - h], xs[j]
			}
		}
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_shell_sort :: proc(t: ^testing.T) {
	test_sort_int_helper(t, proc(xs: []int) {shell_sort(xs)})
}

@(test)
test_shell_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {shell_sort(xs)})
}

@(test)
test_shell_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {shell_sort_by(xs, less)},
	)
}

