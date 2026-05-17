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

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
quick_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to quick_sort.
	CUTOFF :: 10

	partition :: proc(xs: []T, lo, hi: int, cmp: proc(a, b: T) -> Cmp) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if cmp(xs[i], ref) != .Less || (i == hi) {break}
			}
			for {
				j -= 1
				if cmp(ref, xs[j]) != .Less || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	sort :: proc(xs: []T, lo, hi: int, cmp: proc(a, b: T) -> Cmp) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1], cmp)
			return
		}

		// Optimization: pick the median of 3 samples across the array
		// to get a better balance between the two sub-arrays.
		mi := median_index_of_3(xs, lo, lo + (hi - lo) / 2, hi, cmp)
		xs[lo], xs[mi] = xs[mi], xs[lo]

		j := partition(xs, lo, hi, cmp)
		sort(xs, lo, j - 1, cmp)
		sort(xs, j + 1, hi, cmp)
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	sort(xs, 0, len(xs) - 1, cmp)
}

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
//
// This version of the quick sort algorithm is optimized for
// cases where the array contains multiple duplicate keys.
// It avoid falling in the worst case (O(N^2)).
three_way_quick_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to quick_sort.
	CUTOFF :: 10

	sort :: proc(xs: []T, lo, hi: int, cmp: proc(a, b: T) -> Cmp) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1], cmp)
			return
		}

		// Optimization: pick the median of 3 samples across the array
		// to get a better balance between the two sub-arrays.
		mi := median_index_of_3(xs, lo, lo + (hi - lo) / 2, hi, cmp)
		xs[lo], xs[mi] = xs[mi], xs[lo]

		lt := lo
		gt := hi
		ref := xs[lo]
		i := lo
		for i <= gt {
			switch cmp(xs[i], ref) {
			case .Less:
				xs[lt], xs[i] = xs[i], xs[lt]
				lt += 1
				i += 1
			case .Greater:
				xs[i], xs[gt] = xs[gt], xs[i]
				gt -= 1
			case .Equal:
				i += 1
			}
		}

		sort(xs, lo, lt - 1, cmp)
		sort(xs, gt + 1, hi, cmp)
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	sort(xs, 0, len(xs) - 1, cmp)
}

// Select the k-th element of the xs slice. Note that this algorithm
// will change the order of the elements in the input slice but not
// in a fully ordered way.
//
// This algorithm uses the same strategy as Quick Sort.
quick_select :: proc(xs: []$T, k: int, cmp: proc(a, b: T) -> Cmp) -> T {

	partition :: proc(xs: []T, lo, hi: int, cmp: proc(a, b: T) -> Cmp) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if cmp(xs[i], ref) != .Less || (i == hi) {break}
			}
			for {
				j -= 1
				if cmp(ref, xs[j]) != .Less || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	lo := 0
	hi := len(xs) - 1
	for hi > lo {
		j := partition(xs, lo, hi, cmp)
		switch {
		case j < k:
			lo = j + 1
		case j > k:
			hi = j - 1
		case:
			return xs[k]
		}
	}
	return xs[k]
}

// -----------------------------------------------
// Utilities
// -----------------------------------------------

// Compute the median of 3 values, using the `less()` procedure
//  parameter to compare elements.
median_index_of_3 :: proc(xs: []$T, lo, mid, hi: int, cmp: proc(a, b: T) -> Cmp) -> int {

	if cmp(xs[lo], xs[mid]) == .Less {
		if cmp(xs[mid], xs[hi]) == .Less {return mid}
		if cmp(xs[lo], xs[hi]) == .Less {return hi}
		return lo
	} else {
		if cmp(xs[lo], xs[hi]) == .Less {return lo}
		if cmp(xs[mid], xs[hi]) == .Less {return hi}
		return mid
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_quick_sort_int :: proc(t: ^testing.T) {

	quick_sort_int :: proc(xs: []int) {quick_sort(xs, cmp_int)}

	test_sort_int_helper(t, quick_sort_int)
}

@(test)
test_quick_sort_f64 :: proc(t: ^testing.T) {

	quick_sort_f64 :: proc(xs: []f64) {quick_sort(xs, cmp_f64)}

	test_sort_float_helper(t, quick_sort_f64)
}

@(test)
test_quick_sort_string :: proc(t: ^testing.T) {

	quick_sort_string :: proc(xs: []string) {quick_sort(xs, cmp_string)}

	test_sort_string_helper(t, quick_sort_string)
}

@(test)
test_quick_sort_string_reverse :: proc(t: ^testing.T) {

	quick_sort_string_reverse :: proc(xs: []string) {quick_sort(xs, cmp_string_reverse)}

	test_sort_string_reverse_helper(t, quick_sort_string_reverse)
}

@(test)
test_median_of_3 :: proc(t: ^testing.T) {

	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 0, 1, 2, cmp_int), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 0, 2, 1, cmp_int), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 1, 0, 2, cmp_int), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 1, 2, 0, cmp_int), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 2, 0, 1, cmp_int), 1)
	testing.expect_value(t, median_index_of_3([]int{11, 12, 13}, 2, 1, 0, cmp_int), 1)
}

@(test)
test_quick_select :: proc(t: ^testing.T) {

	quick_select_int :: proc(xs: []int, k: int) -> int {return quick_select(xs, k, cmp_int)}

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	// the sorted array:
	// {1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	testing.expect_value(t, quick_select_int(xs, 0), 1)
	testing.expect_value(t, quick_select_int(xs, 21), 20)
	testing.expect_value(t, quick_select_int(xs, 10), 10)
}

@(test)
test_three_way_quick_sort_int :: proc(t: ^testing.T) {

	three_way_quick_sort_int :: proc(xs: []int) {three_way_quick_sort(xs, cmp_int)}

	test_sort_int_helper(t, three_way_quick_sort_int)
}

@(test)
test_three_way_quick_sort_f64 :: proc(t: ^testing.T) {

	three_way_quick_sort_f64 :: proc(xs: []f64) {three_way_quick_sort(xs, cmp_f64)}

	test_sort_float_helper(t, three_way_quick_sort_f64)
}

@(test)
test_three_way_quick_sort_string :: proc(t: ^testing.T) {

	three_way_quick_sort_string :: proc(xs: []string) {three_way_quick_sort(xs, cmp_string)}

	test_sort_string_helper(t, three_way_quick_sort_string)
}

@(test)
test_three_way_quick_sort_string_reverse :: proc(t: ^testing.T) {

	three_way_quick_sort_string_reverse :: proc(xs: []string) {three_way_quick_sort(
			xs,
			cmp_string_reverse,
		)}

	test_sort_string_reverse_helper(t, three_way_quick_sort_string_reverse)
}

