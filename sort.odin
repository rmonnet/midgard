// This file contains the implementation for different sort algorithms.
package midgard

import "core:math/rand"
import "core:testing"

// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// Its performance is O(N^2).
selection_sort :: proc(xs: []$T) {

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
insertion_sort :: proc(xs: []$T) {

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
shell_sort :: proc(xs: []$T) {

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
