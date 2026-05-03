// This file provides utilities to help with tests.
// This function provides informative error reports.
package midgard

import "core:fmt"
import "core:testing"

// Compare two string slices in a manner that provides informative feedback when the test fails.
expect_string_slices :: proc(t: ^testing.T, actual, expected: []string, loc := #caller_location) {

	result := fmt.aprintf("%s", actual)
	exp_str := fmt.aprintf("%s", expected)
	defer {
		delete(result)
		delete(exp_str)
	}
	testing.expect_value(t, result, exp_str, loc = loc)
}

// Compare two slices in a manner that provides informative feedback when the test fails.
expect_slices :: proc(t: ^testing.T, actual, expected: []$E, loc := #caller_location) {

	result := fmt.aprintf("%v", actual)
	exp_str := fmt.aprintf("%v", expected)
	defer {
		delete(result)
		delete(exp_str)
	}
	testing.expect_value(t, result, exp_str, loc = loc)
}
