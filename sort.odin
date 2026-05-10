// This file contains the implementation for different sort algorithms.
package midgard

import "base:intrinsics"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:slice"
import "core:testing"

// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// Its performance is O(N^2).
selection_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if xs[j] < xs[min_j] {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right using the
// procedure less for comparison.
//
// Its performance is O(N^2).
selection_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if less(xs[j], xs[min_j]) {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

// Insertion sort sorts the xs array in place
// by examining each element, considering the elements
// on its left to be in order and moving backward,
// exchanging the element with the one considered
// as long as the element is smaller than the considered
// element.
//
// Its performance is O(N^2).
// It can be faster than selection sort
// if the original array is partially sorted.
insertion_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if !(xs[j] < xs[j - 1]) {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

// Insertion sort sorts the xs array in place
// by examining each element, considering the elements
// on its left to be in order and moving backward,
// exchanging the element with the one considered
// as long as the element is smaller than the considered
// element. It uses the procedure less when comparing the
// elements.
//
// Its performance is O(N^2).
// It can be faster than selection sort
// if the original array is partially sorted.
insertion_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if !less(xs[j], xs[j - 1]) {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

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

// Merge sort sorts the xs array by recursively dividing the array
// into two sub-arrays, sorting them and merging them back into the main
// array.
//
// Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
merge_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to merge_sort.
	CUTOFF :: 7

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int) {

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
			} else if aux[j] < aux[i] {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	sort :: proc(xs: []$T, aux: []T, lo: int, hi: int) {

		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1])
			return
		}

		mid := lo + (hi - lo) / 2
		sort(xs, aux, lo, mid)
		sort(xs, aux, mid + 1, hi)
		if !(xs[mid + 1] < xs[mid]) {return}
		merge(xs, aux, lo, mid, hi)
	}


	aux := make([]T, len(xs))
	defer delete(aux)
	sort(xs, aux, 0, len(xs) - 1)
}

// Merge sort sorts the xs array by recursively dividing the array
// into two sub-arrays, sorting them and merging them back into the main
// array. It uses the procedure less when comparing elements.
//
// Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
merge_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to merge_sort.
	CUTOFF :: 7

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int, less: proc(a, b: T) -> bool) {

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
			} else if less(aux[j], aux[i]) {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	sort :: proc(xs: []$T, aux: []T, lo: int, hi: int, less: proc(a, b: T) -> bool) {

		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1])
			return
		}

		mid := lo + (hi - lo) / 2
		sort(xs, aux, lo, mid, less)
		sort(xs, aux, mid + 1, hi, less)
		if !(xs[mid + 1] < xs[mid]) {return}
		merge(xs, aux, lo, mid, hi, less)
	}


	aux := make([]T, len(xs))
	defer delete(aux)
	sort(xs, aux, 0, len(xs) - 1, less)
}

// Bottom Merge sort sorts the xs array by incrementally sorting
// larger and larger sections of the array using the merge portion
// of the sort algorithm. It starts with a section of size 2 and double
// the size with each iteration until the entire array is covered.
//
// Bottom Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
bottom_merge_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int) {

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
			} else if aux[j] < aux[i] {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	aux := make([]T, len(xs))
	defer delete(aux)

	for size := 1; size < len(xs); size *= 2 {
		for lo := 0; lo < len(xs) - size; lo += 2 * size {
			merge(xs, aux, lo, lo + size - 1, min(lo + 2 * size - 1, len(xs) - 1))
		}
	}
}

bottom_merge_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int, less: proc(a, b: T) -> bool) {

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
			} else if less(aux[j], aux[i]) {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	aux := make([]T, len(xs))
	defer delete(aux)

	for size := 1; size < len(xs); size *= 2 {
		for lo := 0; lo < len(xs) - size; lo += 2 * size {
			merge(xs, aux, lo, lo + size - 1, min(lo + 2 * size - 1, len(xs) - 1), less)
		}
	}
}

// Shuffle uniformly shuffle the values in an array.
//
// The resulting random distribution is uniform.
shuffle :: proc(xs: []$T) {

	// Note: randomly exchanging each card with another
	// card in the array doesn't result in a uniform distribution.
	// Exchanging each card with a card to its left does.
	for i in 1 ..< len(xs) {
		j := rand.int_max(i + 1)
		xs[i], xs[j] = xs[j], xs[i]
	}
}


// -----------------------------------------------
// Tests
// -----------------------------------------------

@(private = "file")
fill_int_array :: proc($N: int) -> [N]int {

	xs: [N]int
	for i in 0 ..< N {
		xs[i] = i + 1
	}
	return xs
}

@(private = "file")
string_less :: proc(a, b: string) -> bool {

	return a < b
}

@(private = "file")
is_sorted :: proc(xs: []$T) -> bool {

	for i in 0 ..< len(xs) - 1 {
		if xs[i] > xs[i + 1] {
			return false
		}
	}
	return true
}

@(private = "file")
test_sort_int_helper :: proc(t: ^testing.T, sort: proc(_: []int), loc := #caller_location) {

	xs := [?]int{5, 1, 10, 3, 9, 2, 8, 7, 6, 4, 2}
	expected := [?]int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	sort(xs[:])

	expect_slices(t, xs[:], expected[:], loc)
}

@(private = "file")
test_sort_float_helper :: proc(t: ^testing.T, sort: proc(_: []f64), loc := #caller_location) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {
		xs[i] = rand.float64()
	}
	sort(xs[:])

	testing.expect(t, is_sorted(xs[:]), loc = loc)
}

@(private = "file")
test_sort_by_string_helper :: proc(
	t: ^testing.T,
	sort_by: proc(_: []string, _: proc(a, b: string) -> bool),
	loc := #caller_location,
) {

	xs := [?]string{"e", "a", "j", "c", "i", "b", "h", "g", "f", "d", "b"}
	expected := [?]string{"a", "b", "b", "c", "d", "e", "f", "g", "h", "i", "j"}
	sort_by(xs[:], string_less)

	expect_string_slices(t, xs[:], expected[:], loc)
}

// Test selection sort

@(test)
test_selection_sort :: proc(t: ^testing.T) {
	test_sort_int_helper(t, proc(xs: []int) {selection_sort(xs)})
}

@(test)
test_selection_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {selection_sort(xs)})
}

@(test)
test_selection_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {selection_sort_by(xs, less)},
	)
}

// Test insertion sort

@(test)
test_insertion_sort :: proc(t: ^testing.T) {
	test_sort_int_helper(t, proc(xs: []int) {insertion_sort(xs)})
}

@(test)
test_insertion_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {insertion_sort(xs)})
}

@(test)
test_insertion_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {insertion_sort_by(xs, less)},
	)
}

// Test shell sort

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

// Test merge sort

@(test)
test_merge_sort :: proc(t: ^testing.T) {
	test_sort_int_helper(t, proc(xs: []int) {merge_sort(xs)})
}

@(test)
test_merge_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {merge_sort(xs)})
}

@(test)
test_merge_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {merge_sort_by(xs, less)},
	)
}

// Test bottom merge sort

@(test)
test_bottom_merge_sort :: proc(t: ^testing.T) {
	test_sort_int_helper(t, proc(xs: []int) {bottom_merge_sort(xs)})
}

@(test)
test_bottom_merge_sort_large :: proc(t: ^testing.T) {
	test_sort_float_helper(t, proc(xs: []f64) {bottom_merge_sort(xs)})
}

@(test)
test_bottom_merge_sort_by :: proc(t: ^testing.T) {
	test_sort_by_string_helper(
		t,
		proc(xs: []string, less: proc(a, b: string) -> bool) {bottom_merge_sort_by(xs, less)},
	)
}

// Test shuffling

@(test)
test_shuffle :: proc(t: ^testing.T) {

	xs := fill_int_array(1000)
	ys := slice.clone(xs[:])
	defer delete(ys)
	shuffle(ys)
	// We need at least 40% of the elements in a different position
	different := 0
	for i in 0 ..< len(xs) {
		if xs[i] != ys[i] {
			different += 1
		}
	}
	testing.expect(t, different > 400, msg = "At least 40% of elements in the wrong position")
	slice.sort(ys)
	expect_slices(t, ys, xs[:])
}

