// This file contains the implementation for the quick  sort algorithm.
//
// Quick sort sorts the xs array by recursively partitioning the array
// into two sub-arrays where elements in the first sub-array are less than
// a selected element and elements in the second sub-array are greater than
// a selected element. The selected element is moved between the two sub-arrays
// and then each sub-array is sorted recursively.
//
// Quick sort sorts the array in-place and doesn't require a secondary array
// like merge sort does.
//
// The sort is not stable.
// Its worse time is O(N^2) but its average time is O(N . lgN). If we start by randomly
// shuffling the array, we have a high probability than the runtime will be close to the average
// time. In this case it is faster than merge sort because there are less element swapping.
package midgard

import "base:intrinsics"
import "core:testing"

// Sort the xs slice in-place.
quick_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to quick_sort.
	CUTOFF :: 10

	partition :: proc(xs: []T, lo, hi: int) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if !(xs[i] < ref) || (i == hi) {break}
			}
			for {
				j -= 1
				if !(ref < xs[j]) || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	sort :: proc(xs: []T, lo, hi: int) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1])
			return
		}

		// Optimization: pick the median of 3 samples across the array
		// to get a better balance between the two sub-arrays.
		mi := median_index_of_3(xs, lo, lo + (hi - lo) / 2, hi)
		xs[lo], xs[mi] = xs[mi], xs[lo]

		j := partition(xs, lo, hi)
		sort(xs, lo, j - 1)
		sort(xs, j + 1, hi)
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	sort(xs, 0, len(xs) - 1)
}

// Sort the xs slice in place, using the `less()` procedure
//  parameter to compare elements.
quick_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to quick_sort.
	CUTOFF :: 10

	partition :: proc(xs: []T, lo, hi: int, less: proc(a, b: T) -> bool) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if !less(xs[i], ref) || (i == hi) {break}
			}
			for {
				j -= 1
				if !less(ref, xs[j]) || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	sort :: proc(xs: []T, lo, hi: int, less: proc(a, b: T) -> bool) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort_by(xs[lo:hi + 1], less)
			return
		}

		// Optimization: pick the median of 3 samples across the array
		// to get a better balance between the two sub-arrays.
		mi := median_index_of_3_by(xs, lo, lo + (hi - lo) / 2, hi, less)
		xs[lo], xs[mi] = xs[mi], xs[lo]

		j := partition(xs, lo, hi, less)
		sort(xs, lo, j - 1, less)
		sort(xs, j + 1, hi, less)
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	sort(xs, 0, len(xs) - 1, less)
}

// -----------------------------------------------
// Utilities
// -----------------------------------------------

// Compute the median of 3 values.
median_index_of_3 :: proc(xs: []$T, lo, mid, hi: int) -> int where intrinsics.type_is_ordered(T) {

	if xs[lo] < xs[mid] {
		if xs[mid] < xs[hi] {return mid}
		if xs[lo] < xs[hi] {return hi}
		return lo
	} else {
		if xs[lo] < xs[hi] {return lo}
		if xs[mid] < xs[hi] {return hi}
		return mid
	}
}

// Compute the median of 3 values, using the `less()` procedure
//  parameter to compare elements.
median_index_of_3_by :: proc(xs: []$T, lo, mid, hi: int, less: proc(a, b: T) -> bool) -> int {

	if less(xs[lo], xs[mid]) {
		if less(xs[mid], xs[hi]) {return mid}
		if less(xs[lo], xs[hi]) {return hi}
		return lo
	} else {
		if less(xs[lo], xs[hi]) {return lo}
		if less(xs[mid], xs[hi]) {return hi}
		return mid
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_quick_sort :: proc(t: ^testing.T) {

	quick_sort_int :: proc(xs: []int) {quick_sort(xs)}

	test_sort_int_helper(t, quick_sort_int)
}

@(test)
test_quick_sort_large :: proc(t: ^testing.T) {

	quick_sort_f64 :: proc(xs: []f64) {quick_sort(xs)}

	test_sort_float_helper(t, quick_sort_f64)
}

@(test)
test_quick_sort_by :: proc(t: ^testing.T) {

	quick_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		quick_sort_by(xs, less)
	}

	test_sort_by_string_helper(t, quick_sort_string_by)
}

@(test)
test_quick_sort_by_reverse :: proc(t: ^testing.T) {

	quick_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		quick_sort_by(xs, less)
	}

	test_sort_by_string_reverse_helper(t, quick_sort_string_by)
}

@(test)
test_median_of_3 :: proc(t: ^testing.T) {

	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 0, 1, 2), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 0, 2, 1), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 1, 0, 2), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 1, 2, 0), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 2, 0, 1), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 2, 1, 0), 1)
}

@(test)
test_median_of_3_by :: proc(t: ^testing.T) {

	lt_int :: proc(a, b: int) -> bool {return a < b}

	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 0, 1, 2, lt_int), 1)
	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 0, 2, 1, lt_int), 1)
	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 1, 0, 2, lt_int), 1)
	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 1, 2, 0, lt_int), 1)
	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 2, 0, 1, lt_int), 1)
	testing.expect_value(t, median_index_of_3_by([]int{11, 12, 13}, 2, 1, 0, lt_int), 1)
}

