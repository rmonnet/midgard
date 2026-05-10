package midgard_math
// Note: The package name doesn't have to be the same as the directory name.
// It just has to be unique among all the source code visible to the compiler.
// What is use as package prefix when referencing objects from the source code
// is the last part of the package directory path and even that can be aliased.
//
// In this case
// import mm "midgard/math" will use `mm.` as the prefix
// import "midgard/math" will use `math.` as the prefix

import "core:testing"

add :: proc(a: int, b: int) -> int {
	return a + b
}

@(test)
test_add :: proc(t: ^testing.T) {
	result := add(2, 3)
	testing.expect_value(t, result, 5)
}
