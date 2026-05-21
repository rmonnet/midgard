// This file provides utilities to help with tests.
// This function provides informative error reports.
package test

import alg ".."
import "base:intrinsics"
import "core:fmt"
import "core:testing"

// `expect_string_slices` compares two string slices in a manner that provides informative
// feedback when the test fails.
expect_string_slices :: proc(t: ^testing.T, actual, expected: []string, loc := #caller_location) {

	result := fmt.aprintf("%s", actual)
	exp_str := fmt.aprintf("%s", expected)
	defer {
		delete(result)
		delete(exp_str)
	}
	testing.expect_value(t, result, exp_str, loc = loc)
}

// `expect_slices` compares two slices in a manner that provides informative feedback when the
// test fails.
expect_slices :: proc(t: ^testing.T, actual, expected: []$E, loc := #caller_location) {

	result := fmt.aprintf("%v", actual)
	exp_str := fmt.aprintf("%v", expected)
	defer {
		delete(result)
		delete(exp_str)
	}
	testing.expect_value(t, result, exp_str, loc = loc)
}

// `fill_int_array` initializes an array with integer from 0 to N (exclusive).
fill_int_array :: proc($N: int) -> [N]int {

	xs: [N]int
	for i in 0 ..< N {
		xs[i] = i + 1
	}
	return xs
}

// `is_sorted` checks if a slice is sorted.
is_sorted :: proc(xs: []$T) -> bool where intrinsics.type_is_comparable(T) {

	for i in 0 ..< len(xs) - 1 {
		if xs[i] > xs[i + 1] {return false}
	}
	return true
}

// `cmp_int` compares two int values and returns if the first is less, equal, or greater
// than the second.
cmp_int :: proc(a, b: int) -> alg.Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

// `cmp_f64` compares two f64 values and returns if the first is less, equal, or greater
// than the second.
cmp_f64 :: proc(a, b: f64) -> alg.Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

// `cmp_string` compares two string values and returns if the first is less, equal, or greater
// than the second.
cmp_string :: proc(a, b: string) -> alg.Cmp {

	if a < b {return .Less}
	if a > b {return .Greater}
	return .Equal
}

// `cmp_string_rev` compares two string values and returns the reverse result of `cmp_string`.
cmp_string_rev :: proc(a, b: string) -> alg.Cmp {

	if a < b {return .Greater}
	if a > b {return .Less}
	return .Equal
}

