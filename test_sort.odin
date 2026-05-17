// This file contains common utilities to test the different sort algorithms.
package midgard

import "core:math/rand"
import "core:testing"

@(private)
fill_int_array :: proc($N: int) -> [N]int {

	xs: [N]int
	for i in 0 ..< N {
		xs[i] = i + 1
	}
	return xs
}

@(private)
is_sorted :: proc(xs: []$T) -> bool {

	for i in 0 ..< len(xs) - 1 {
		if xs[i] > xs[i + 1] {
			return false
		}
	}
	return true
}

@(private)
test_sort_int_helper :: proc(t: ^testing.T, sort: proc(_: []int), loc := #caller_location) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	sort(xs)

	expect_slices(t, xs, expected, loc)
}

@(private)
test_sort_float_helper :: proc(t: ^testing.T, sort: proc(_: []f64), loc := #caller_location) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {
		xs[i] = rand.float64()
	}
	sort(xs[:])

	testing.expect(t, is_sorted(xs[:]), loc = loc)
}

@(private)
test_sort_string_helper :: proc(t: ^testing.T, sort: proc(_: []string), loc := #caller_location) {

	xs := []string {
		"q",
		"e",
		"t",
		"a",
		"l",
		"j",
		"r",
		"c",
		"i",
		"p",
		"b",
		"m",
		"n",
		"h",
		"g",
		"f",
		"d",
		"l",
		"b",
		"s",
		"o",
		"k",
	}
	expected := []string {
		"a",
		"b",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
	}
	sort(xs)

	expect_string_slices(t, xs, expected, loc)
}

@(private)
test_sort_string_reverse_helper :: proc(
	t: ^testing.T,
	sort_reverse: proc(_: []string),
	loc := #caller_location,
) {

	xs := []string {
		"q",
		"e",
		"t",
		"a",
		"l",
		"j",
		"r",
		"c",
		"i",
		"p",
		"b",
		"m",
		"n",
		"h",
		"g",
		"f",
		"d",
		"l",
		"b",
		"s",
		"o",
		"k",
	}
	expected := []string {
		"t",
		"s",
		"r",
		"q",
		"p",
		"o",
		"n",
		"m",
		"l",
		"l",
		"k",
		"j",
		"i",
		"h",
		"g",
		"f",
		"e",
		"d",
		"c",
		"b",
		"b",
		"a",
	}
	sort_reverse(xs)

	expect_string_slices(t, xs, expected, loc)
}

