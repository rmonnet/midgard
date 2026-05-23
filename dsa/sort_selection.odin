// This file contains the implementation for the selection sort algorithm.
//
// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `lesls_than` procedure to specify all the
// comparison operators for the set.
//
// The sort is not stable.
// Its performance is O(N^2).
package dsa

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
selection_sort :: proc(xs: []$T, lesls_than: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if lesls_than(xs[j], xs[min_j]) {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

// ------------------------------------------
// Tests
// ------------------------------------------

import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

@(test)
sls_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	selection_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
sls_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	selection_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

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
sls_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	selection_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
sls_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	selection_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

