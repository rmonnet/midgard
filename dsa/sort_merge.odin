// This file contains the implementation for the merge sort algorithm.
//
// Merge sort sorts the xs array by recursively dividing the array
// into two sub-arrays, sorting them and merging them back into the main
// array.
//
// Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `less_than` procedure to specify all the
// comparison operators for the set.
//
// The sort is stable.
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
package dsa

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
merge_sort :: proc(xs: []$T, less_than: proc(a, b: T) -> bool) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to merge_sort.
	CUTOFF :: 7

	merge :: proc(
		xs: []$T,
		aux: []T,
		lo: int,
		mid: int,
		hi: int,
		less_than: proc(a, b: T) -> bool,
	) {

		copy(aux[lo:hi + 1], xs[lo:hi + 1])
		i := lo
		j := mid + 1
		for k in lo ..= hi {
			if i > mid {
				xs[k] = aux[j]
				j += 1
			} else if j > hi {
				xs[k] = aux[i]
				i += 1
			} else if less_than(aux[j], aux[i]) {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	sort :: proc(xs: []$T, aux: []T, lo: int, hi: int, less_than: proc(a, b: T) -> bool) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1], less_than)
			return
		}

		mid := lo + (hi - lo) / 2
		sort(xs, aux, lo, mid, less_than)
		sort(xs, aux, mid + 1, hi, less_than)
		if !less_than(xs[mid + 1], xs[mid]) {return}
		merge(xs, aux, lo, mid, hi, less_than)
	}


	aux := make([]T, len(xs))
	defer delete(aux)
	sort(xs, aux, 0, len(xs) - 1, less_than)
}

// Tests
// -----

import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

@(test)
ms_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	merge_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
ms_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	merge_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

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
ms_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	merge_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
ms_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	merge_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

