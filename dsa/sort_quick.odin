// This file contains the implementation for the quick  sort algorithm.
package dsa

/*
# Quick Sort Algorithm

## Summary

Quick sort sorts the xs array by recursively partitioning the array
into two sub-arrays where elements in the first sub-array are less than
a selected element and elements in the second sub-array are greater than
a selected element. The selected element is moved between the two sub-arrays
and then each sub-array is sorted recursively.

## Notes

Quick sort sorts the array in-place and doesn't require a secondary array
like merge sort does.

We are assuming that the element type is Totally Ordered and that
we only need to define the `less_than` procedure to specify all the
comparison operators for the set.

## Properties

The sort is not stable.
Its worse time is O(N^2) but its average time is O(N . lgN). If we start by randomly
shuffling the array, we have a high probability than the runtime will be close to the average
time. In this case it is faster than merge sort because there are less element swapping.
*/

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
quick_sort :: proc(xs: []$T, less_than: proc(a, b: T) -> bool) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to quick_sort.
	CUTOFF :: 10

	partition :: proc(xs: []T, lo, hi: int, less_than: proc(a, b: T) -> bool) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if !less_than(xs[i], ref) || (i == hi) {break}
			}
			for {
				j -= 1
				if !less_than(ref, xs[j]) || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	sort :: proc(xs: []T, lo, hi: int, less_than: proc(a, b: T) -> bool) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1], less_than)
			return
		}

		// Optimization: pick the median of 3 samples across the array
		// to get a better balance between the two sub-arrays.
		mi := median_index_of_3(xs, lo, lo + (hi - lo) / 2, hi, less_than)
		xs[lo], xs[mi] = xs[mi], xs[lo]

		j := partition(xs, lo, hi, less_than)
		sort(xs, lo, j - 1, less_than)
		sort(xs, j + 1, hi, less_than)
	}

	// Compute the median of 3 values, using the `less()` procedure
	//  parameter to compare elements.
	median_index_of_3 :: proc(
		xs: []$T,
		lo, mid, hi: int,
		less_than: proc(a, b: T) -> bool,
	) -> int {

		if less_than(xs[lo], xs[mid]) {
			if less_than(xs[mid], xs[hi]) {return mid}
			if less_than(xs[lo], xs[hi]) {return hi}
			return lo
		} else {
			if less_than(xs[lo], xs[hi]) {return lo}
			if less_than(xs[mid], xs[hi]) {return hi}
			return mid
		}
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	sort(xs, 0, len(xs) - 1, less_than)
}

// ------------------------------------------
// Tests
// ------------------------------------------

import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

@(test)
qs_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	quick_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
qs_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	quick_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

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
qs_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	quick_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
qs_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	quick_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

