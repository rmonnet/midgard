// This file contains the implementation for the insertion sort algorithm.
package midgard

import "base:intrinsics"
import "core:testing"

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

// -----------------------------------------------
// Tests
// -----------------------------------------------

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

