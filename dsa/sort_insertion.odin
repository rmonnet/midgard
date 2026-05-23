// This file contains the implementation for the insertion sort algorithm.
//
// Insertion sort sorts the xs array in place by examining each element, considering the elements
// on its left to be in order and moving backward, exchanging the element with the one considered
// as long as the element is smaller than the considered element.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `less_than` procedure to specify all the
// comparison operators for the set.
// The sort is stable.
// Its performance is O(N^2).
// It can be faster than selection sort
// if the original array is partially sorted.
package dsa

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
insertion_sort :: proc(xs: []$T, less_than: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if !less_than(xs[j], xs[j - 1]) {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
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
is_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	insertion_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
is_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	insertion_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

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
is_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	insertion_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
is_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	insertion_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

