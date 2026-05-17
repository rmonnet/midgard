// This file contains the implementation for the shell sort algorithm.
//
// Shell sort sorts the xs array as an h array
// (that is considering only the h-th elements of the array)
// using insertion sort. It then continues to do so while
// decreasing the value of h down to 1.
//
// The sort is not stable.
// This is efficient because 1) the h-array stays sorted as we decrease
// the value of h and 2) insertion sort is efficient when used with partially
// sorted arrays.
package midgard

import "base:intrinsics"
import "core:testing"

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
shell_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	h := 1
	for h < len(xs) / 3 {
		h = 3 * h + 1
	}
	for ; h >= 1; h = h / 3 {
		for i := h; i < len(xs); i += 1 {
			for j := i; j >= h; j -= h {
				if cmp(xs[j], xs[j - h]) != .Less {break}
				xs[j], xs[j - h] = xs[j - h], xs[j]
			}
		}
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_shell_sort_int :: proc(t: ^testing.T) {

	shell_sort_int :: proc(xs: []int) {shell_sort(xs, cmp_int)}

	test_sort_int_helper(t, shell_sort_int)
}

@(test)
test_shell_sort_f64 :: proc(t: ^testing.T) {

	shell_sort_f64 :: proc(xs: []f64) {shell_sort(xs, cmp_f64)}

	test_sort_float_helper(t, shell_sort_f64)
}

@(test)
test_shell_sort_string :: proc(t: ^testing.T) {

	shell_sort_string :: proc(xs: []string) {shell_sort(xs, cmp_string)}

	test_sort_string_helper(t, shell_sort_string)
}

@(test)
test_shell_sort_string_reverse :: proc(t: ^testing.T) {

	shell_sort_string_reverse :: proc(xs: []string) {shell_sort(xs, cmp_string_reverse)}

	test_sort_string_reverse_helper(t, shell_sort_string_reverse)
}

