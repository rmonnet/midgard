// This file contains the implementation for the shell sort algorithm.
//
// Shell sort sorts the xs array as an h array
// (that is considering only the h-th elements of the array)
// using insertion sort. It then continues to do so while
// decreasing the value of h down to 1.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `less_than` procedure to specify all the
// comparison operators for the set.
//
// The sort is not stable.
// This is efficient because 1) the h-array stays sorted as we decrease
// the value of h and 2) insertion sort is efficient when used with partially
// sorted arrays.
package dsa

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
shell_sort :: proc(xs: []$T, less_than: proc(a, b: T) -> bool) {

	h := 1
	for h < len(xs) / 3 {
		h = 3 * h + 1
	}
	for ; h >= 1; h = h / 3 {
		for i := h; i < len(xs); i += 1 {
			for j := i; j >= h; j -= h {
				if !less_than(xs[j], xs[j - h]) {break}
				xs[j], xs[j - h] = xs[j - h], xs[j]
			}
		}
	}
}

// Tests
// -----

import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

@(test)
ss_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	shell_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
ss_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	shell_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

	// Checking that the array is sorted
	for i in 1 ..< len(xs) {
		if xs[i - 1] >= xs[i] {
			testing.expectf(
				t,
				false,
				"Sort fails: xs[%d](%f) >= xs[%d](%f)\n",
				i - 1,
				xs[i - 1],
				i,
				xs[i],
			)
		}
	}
}

@(test)
ss_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	shell_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
ss_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	shell_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

